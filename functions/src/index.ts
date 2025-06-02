import {onDocumentCreated} from "firebase-functions/v2/firestore";
import {onTaskDispatched} from "firebase-functions/v2/tasks";
import {getFunctions} from "firebase-admin/functions";
import * as admin from "firebase-admin";
import axios from "axios";

/* eslint-disable */

admin.initializeApp();

// OneSignal Configuration
const ONESIGNAL_APP_ID = "6486fc75-cf18-49fb-9d43-bca5c7990f54";
const ONESIGNAL_REST_API_KEY =
"os_v2_app_msdpy5opdbe7xhkdxss4pgipkskckdogfx4epj55a" +
"g2rblqsh3xyfdp6ecspcvit5upyanpst6utcnusf33dygxjn7kn37pkpsxb36y";
const ONESIGNAL_API_URL = "https://onesignal.com/api/v1/notifications";
const MOROCCO_TIMEZONE_OFFSET = 1;

interface OneSignalNotification {
app_id: string;
include_external_user_ids: string[];
exclude_external_user_ids: string[];
contents: {[key: string]: string};
headings: {[key: string]: string};
data?: {[key: string]: unknown};
}

interface TaskPayload {
eventId: string;
eventTitle: string;
registeredUsers: string[];
notificationType: "reminder" | "start";
}

/**
* Converts UTC timestamp to Morocco time
* @param {admin.firestore.Timestamp} utcTimesTamp - UTC timestamp
* @return {Date} Morocco time
*/
function toMoroccoTime(utcTimesTamp: admin.firestore.Timestamp): Date {
  const utcDate = utcTimesTamp.toDate();
  const moroccoTime = new Date(
    utcDate.getTime() + (MOROCCO_TIMEZONE_OFFSET * 60 * 60 * 1000)
  );
  return moroccoTime;
}

/**
* Sends notification via OneSignal API
* @param {OneSignalNotification} notification - Notification payload
*/
async function sendOneSignalNotification(
  notification: OneSignalNotification
): Promise<void> {
  try {
    const response = await axios.post(ONESIGNAL_API_URL, notification, {
      headers: {
        "Content-Type": "application/json",
        "Authorization": `Basic ${ONESIGNAL_REST_API_KEY}`,
      },
    });
    console.log("Notification sent successfully:", response.data);
  } catch (error) {
    console.error("Error sending notification:", error);
  }
}

// Function 1: Send immediate notification to all non-staff users when new event is created
export const notifyNewEventCreation = onDocumentCreated(
  "events/{eventId}",
  async (event) => {
    const eventData = event.data?.data();
    const eventId = event.params.eventId;

    if (!eventData) {
      console.log("Event data is undefined, skipping new event notification");
      return;
    }

    try {
      // Get all users who are not staff
      const usersSnapshot = await admin.firestore()
        .collection("user_profiles")
        .where("staff?", "==", false)
        .get();

      if (usersSnapshot.empty) {
        console.log("No non-staff users found");
        return;
      }

      // Extract user IDs
      const nonStaffUserIds = usersSnapshot.docs.map((doc) => doc.id);

      const notification: OneSignalNotification = {
        app_id: ONESIGNAL_APP_ID,
        include_external_user_ids: nonStaffUserIds,
        exclude_external_user_ids: [],
        headings: {en: "🎉 New Event Available!"},
        contents: {
          en: `Check out the new event: "${eventData.eventName}"`,
        },
        data: {
          type: "new_event",
          eventId: eventId,
          eventTitle: eventData.title,
          eventDescription: eventData.eventDescription || "",
        },
      };

      await sendOneSignalNotification(notification);
      console.log(
        `New event notification sent to ${nonStaffUserIds.length} non-staff users`
      );

      // Schedule reminder and start notification tasks if event has a start date
      if (eventData.startDate) {
        await scheduleEventTasks(eventId, eventData);
      }
    } catch (error) {
      console.error("Error sending new event notification:", error);
    }
  });

/**
* Schedules reminder and start notification tasks for an event
*/
async function scheduleEventTasks(eventId: string, eventData: any): Promise<void> {
  const startDate = eventData.startDate as admin.firestore.Timestamp;
  const moroccoStartTime = toMoroccoTime(startDate);

  // Calculate reminder time (1 hour before event starts)
  const reminderTime = new Date(moroccoStartTime.getTime() - (60 * 60 * 1000));

  const queue = getFunctions().taskQueue("eventNotifications");

  // Schedule reminder task (1 hour before)
  if (reminderTime > new Date()) {
    const reminderPayload: TaskPayload = {
      eventId: eventId,
      eventTitle: eventData.title,
      registeredUsers: [], // Will be fetched at execution time
      notificationType: "reminder",
    };

    await queue.enqueue(reminderPayload, {
      scheduleTime: reminderTime,
      id: `reminder-${eventId}`,
    });

    console.log(`Reminder task scheduled for ${reminderTime.toISOString()}`);
  }

  // Schedule start notification task
  if (moroccoStartTime > new Date()) {
    const startPayload: TaskPayload = {
      eventId: eventId,
      eventTitle: eventData.title,
      registeredUsers: [], // Will be fetched at execution time
      notificationType: "start",
    };

    await queue.enqueue(startPayload, {
      scheduleTime: moroccoStartTime,
      id: `start-${eventId}`,
    });

    console.log(`Start notification task scheduled for ${moroccoStartTime.toISOString()}`);
  }
}

// Function 2: Handle scheduled notification tasks
export const eventNotifications = onTaskDispatched(
  {
    retryConfig: {
      maxAttempts: 3,
      minBackoffSeconds: 60,
    },
    rateLimits: {
      maxConcurrentDispatches: 10,
    },
  },
  async (req) => {
    const payload = req.data as TaskPayload;
    const {eventId, eventTitle, notificationType} = payload;

    try {
      // Fetch current event data to get latest registered users
      const eventDoc = await admin.firestore()
        .collection("events")
        .doc(eventId)
        .get();

      if (!eventDoc.exists) {
        console.log(`Event ${eventId} no longer exists`);
        return;
      }

      const eventData = eventDoc.data();
      if (!eventData?.registeredUsers || eventData.registeredUsers.length === 0) {
        console.log(`No registered users for event ${eventId}`);
        return;
      }

      let notification: OneSignalNotification;

      if (notificationType === "reminder") {
        notification = {
          app_id: ONESIGNAL_APP_ID,
          include_external_user_ids: eventData.registeredUsers,
          exclude_external_user_ids: [],
          headings: {en: "🔔 Event Reminder"},
          contents: {
            en: `"${eventTitle}" starts in 1 hour!`,
          },
          data: {
            type: "event_reminder",
            eventId: eventId,
            eventTitle: eventTitle,
          },
        };
        console.log(`Sending reminder for "${eventTitle}" to ${eventData.registeredUsers.length} users`);
      } else {
        notification = {
          app_id: ONESIGNAL_APP_ID,
          include_external_user_ids: eventData.registeredUsers,
          exclude_external_user_ids: [],
          headings: {en: "🚀 Event Started!"},
          contents: {
            en: `"${eventTitle}" is starting now!`,
          },
          data: {
            type: "event_started",
            eventId: eventId,
            eventTitle: eventTitle,
          },
        };
        console.log(`Sending start notification for "${eventTitle}" to ${eventData.registeredUsers.length} users`);
      }

      await sendOneSignalNotification(notification);
      console.log(`${notificationType} notification sent successfully for event ${eventId}`);
    } catch (error) {
      console.error(`Error sending ${notificationType} notification for event ${eventId}:`, error);
      throw error; // This will trigger retry if configured
    }
  });
