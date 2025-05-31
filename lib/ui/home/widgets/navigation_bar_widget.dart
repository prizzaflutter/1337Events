// import 'package:flutter/cupertino.dart';
//
// Widget _buildNavItem({
//   required IconData icon,
//   required String label,
//   required int index,
// }) {
//   final isSelected = _selectedIndex == index;
//
//   return GestureDetector(
//     onTap: () {
//       setState(() {
//         _selectedIndex = index;
//       });
//     },
//     child: AnimatedContainer(
//       duration: const Duration(milliseconds: 200),
//       padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
//       margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
//       decoration: BoxDecoration(
//         color: isSelected
//             ? Colors.white.withOpacity(0.2)
//             : Colors.transparent,
//         borderRadius: BorderRadius.circular(20),
//         border: isSelected
//             ? Border.all(color: Colors.white.withOpacity(0.3), width: 1)
//             : null,
//       ),
//       child: Row(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           Icon(
//             icon,
//             color: Colors.white,
//             size: isSelected ? 26 : 24,
//           ),
//           if (isSelected) ...[
//             const SizedBox(width: 8),
//             Text(
//               label,
//               style: const TextStyle(
//                 color: Colors.white,
//                 fontSize: 16,
//                 fontWeight: FontWeight.w600,
//               ),
//             ),
//           ],
//         ],
//       ),
//     ),
//   );
// }