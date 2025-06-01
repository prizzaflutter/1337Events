import {onDocumentCreated, onDocumentUpdated} from
  "firebase-functions/v2/firestore";
import {onSchedule} from "firebase-functions/v2/scheduler";
import * as admin from "firebase-admin";
import axios from "axios";

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
send_after?: string; // iso format
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

export const scheduleEventReminders = onDocumentCreated(
  "events/{eventId}",
  async (event) => {
    const eventData = event.data?.data();
    const eventId = event.params.eventId;

    // Add null check for eventData
    if (!eventData) {
      console.log("Event data is undefined, skipping reminder scheduling");
      return;
    }

    if (!eventData.startDate ||
!eventData.registeredUsers ||
eventData.registeredUsers.length === 0) {
      console.log(
        "Event has no start time or registered users, " +
"skipping reminder scheduling"
      );
      return;
    }

    const startDate = eventData.startDate as admin.firestore.Timestamp;
    const moroccoStartTime = toMoroccoTime(startDate);

    // Calculate reminder time (1 hour before event starts in Morocco time)
    const reminderTime = new Date(
      moroccoStartTime.getTime() - (60 * 60 * 1000)
    );

    // Only schedule if reminder time is in the future
    if (reminderTime > new Date()) {
      const notification: OneSignalNotification = {
        app_id: ONESIGNAL_APP_ID,
        include_external_user_ids: eventData.registeredUsers,
        exclude_external_user_ids: [],
        headings: {en: "🔔 Event Reminder"},
        contents: {
          en: `"${eventData.title}" starts in 1 hour!`,
        },
        data: {
          type: "event_reminder",
          eventId: eventId,
          eventTitle: eventData.title,
        },
        send_after: reminderTime.toISOString(),
      };

      await sendOneSignalNotification(notification);
      console.log(
        `Event reminder scheduled for ${reminderTime.toISOString()}`
      );
    } else {
      console.log("Event starts too soon, reminder not scheduled");
    }
  });

// Function 2: Send notification when event actually starts
export const sendEventStartNotifications = onDocumentCreated(
  "events/{eventId}",
  async (event) => {
    const eventData = event.data?.data();
    const eventId = event.params.eventId;

    // Add null check for eventData
    if (!eventData) {
      console.log("Event data is undefined, skipping start notification");
      return;
    }

    if (!eventData.startDate ||
!eventData.registeredUsers ||
eventData.registeredUsers.length === 0) {
      console.log(
        "Event has no start time or registered users, " +
"skipping start notification"
      );
      return;
    }

    const startDate = eventData.startDate as admin.firestore.Timestamp;
    const moroccoStartTime = toMoroccoTime(startDate);

    // Only schedule if start time is in the future
    if (moroccoStartTime > new Date()) {
      const notification: OneSignalNotification = {
        app_id: ONESIGNAL_APP_ID,
        include_external_user_ids: eventData.registeredUsers,
        exclude_external_user_ids: [],
        headings: {en: "🚀 Event Started!"},
        contents: {
          en: `"${eventData.title}" is starting now!`,
        },
        data: {
          type: "event_started",
          eventId: eventId,
          eventTitle: eventData.title,
        },
        send_after: moroccoStartTime.toISOString(),
      };

      await sendOneSignalNotification(notification);
      console.log(
        "Event start notification scheduled for " +
`${moroccoStartTime.toISOString()}`
      );
    } else {
      console.log("Event start time has passed, notification not scheduled");
    }
  });

// Function 3: Send notification to all users (except staff) when new event
// is created
export const notifyNewEventCreation = onDocumentCreated(
  "events/{eventId}",
  async (event) => {
    const eventData = event.data?.data();
    const eventId = event.params.eventId;

    // Add null check for eventData
    if (!eventData) {
      console.log("Event data is undefined, skipping new event notification");
      return;
    }

    try {
      // Get all users who are not staff
      const usersSnapshot = await admin.firestore()
        .collection("user_profiles")
        .where("isStaff", "==", false)
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
          en: `Check out the new event: "${eventData.title}"`,
        },
        data: {
          type: "new_event",
          eventId: eventId,
          eventTitle: eventData.title,
          eventDescription: eventData.description || "",
        },
      };

      await sendOneSignalNotification(notification);
      console.log(
        `New event notification sent to ${nonStaffUserIds.length} ` +
"non-staff users"
      );
    } catch (error) {
      console.error("Error sending new event notification:", error);
    }
  });

// Function 4: Handle event updates (optional - send notifications for
// important changes)
export const handleEventUpdates = onDocumentUpdated(
  "events/{eventId}",
  async (event) => {
    const beforeData = event.data?.before.data();
    const afterData = event.data?.after.data();
    const eventId = event.params.eventId;

    // Add null checks for beforeData and afterData
    if (!beforeData || !afterData) {
      console.log("Before or after data is undefined, skipping event update");
      return;
    }

    // Check if start time changed significantly (more than 30 minutes)
    if (beforeData.startDate && afterData.startDate) {
      const beforeTime = (
beforeData.startDate as admin.firestore.Timestamp
      ).toDate();
      const afterTime = (
afterData.startDate as admin.firestore.Timestamp
      ).toDate();
      const timeDifference = Math.abs(
        afterTime.getTime() - beforeTime.getTime()
      );

      // If time changed by more than 30 minutes, notify registered users
      if (timeDifference > 30 * 60 * 1000 &&
afterData.registeredUsers &&
afterData.registeredUsers.length > 0) {
        const moroccoTime = toMoroccoTime(afterData.startDate);

        const notification: OneSignalNotification = {
          app_id: ONESIGNAL_APP_ID,
          include_external_user_ids: afterData.registeredUsers,
          exclude_external_user_ids: [],
          headings: {en: "⏰ Event Time Updated"},
          contents: {
            en: `"${afterData.title}" time has been updated. ` +
`New time: ${moroccoTime.toLocaleString("en-US", {
  timeZone: "Africa/Casablanca",
})}`,
          },
          data: {
            type: "event_updated",
            eventId: eventId,
            eventTitle: afterData.title,
            newStartTime: moroccoTime.toISOString(),
          },
        };

        await sendOneSignalNotification(notification);
        console.log("Event time update notification sent");
      }
    }
  });

// Function 5: Clean up function to remove old scheduled notifications
// (optional)
export const cleanupOldEvents = onSchedule(
  "every 24 hours",
  async () => {
    const now = admin.firestore.Timestamp.now();
    const oneDayAgo = admin.firestore.Timestamp.fromDate(
      new Date(now.toDate().getTime() - 24 * 60 * 60 * 1000)
    );

    try {
      // Find events that ended more than 24 hours ago
      const oldEventsSnapshot = await admin.firestore()
        .collection("events")
        .where("endDate", "<", oneDayAgo)
        .get();

      console.log(
        `Found ${oldEventsSnapshot.docs.length} old events to clean up`
      );

      // You can add cleanup logic here if needed
      // For example, updating event status, archiving, etc.
    } catch (error) {
      console.error("Error during cleanup:", error);
    }
  });
