import 'package:flutter/material.dart';
import 'package:roberto/app/app_color.dart';

class CustomPagination extends StatelessWidget {
  final int totalItems;
  final int itemsPerPage;
  final int currentPage;
  final Function(int) onPageChanged;

  const CustomPagination({
    super.key,
    required this.totalItems,
    required this.itemsPerPage,
    required this.currentPage,
    required this.onPageChanged,
  });

  @override
  Widget build(BuildContext context) {
    final int totalPages = (totalItems / itemsPerPage).ceil();
    final bool isMobile = MediaQuery.of(context).size.width < 600;

    if (totalItems == 0) return const SizedBox.shrink();

    final int startItem = (currentPage - 1) * itemsPerPage + 1;
    final int endItem = currentPage * itemsPerPage > totalItems
        ? totalItems
        : currentPage * itemsPerPage;

    return Padding(
      padding: EdgeInsets.symmetric(vertical: isMobile ? 12 : 20),
      child: isMobile
          ? Column(
              children: [
                 Text(
                  'Showing $startItem-$endItem of $totalItems',
                  style: TextStyle(
                    fontSize: 13,
                    color: Theme.of(context).textTheme.bodySmall?.color,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildPrevButton(context),
                    const SizedBox(width: 8),
                    _buildNextButton(context, totalPages),
                  ],
                ),
              ],
            )
          : Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Showing $startItem to $endItem of $totalItems entries',
                  style: TextStyle(
                    fontSize: 14,
                    color: Theme.of(context).textTheme.bodySmall?.color,
                  ),
                ),
                Row(
                  children: [
                    _buildPrevButton(context),
                    const SizedBox(width: 8),
                    ..._buildPageNumbers(context, totalPages),
                    const SizedBox(width: 8),
                    _buildNextButton(context, totalPages),
                  ],
                ),
              ],
            ),
    );
  }

  Widget _buildPrevButton(BuildContext context) {
    final bool isFirst = currentPage == 1;
    return OutlinedButton(
      onPressed: isFirst ? null : () => onPageChanged(currentPage - 1),
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColor.primary,
        side: BorderSide(color: AppColor.primary.withOpacity(isFirst ? 0.2 : 0.5)),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.chevron_left, size: 20),
          Text('Previous'),
        ],
      ),
    );
  }

  Widget _buildNextButton(BuildContext context, int totalPages) {
    final bool isLast = currentPage == totalPages || totalPages == 0;
    return OutlinedButton(
      onPressed: isLast ? null : () => onPageChanged(currentPage + 1),
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColor.primary,
        side: BorderSide(color: AppColor.primary.withOpacity(isLast ? 0.2 : 0.5)),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Next'),
          Icon(Icons.chevron_right, size: 20),
        ],
      ),
    );
  }

  List<Widget> _buildPageNumbers(BuildContext context, int totalPages) {
    List<Widget> items = [];
    for (int i = 1; i <= totalPages; i++) {
      final bool isCurrent = i == currentPage;
      items.add(
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 2),
          child: InkWell(
            onTap: () => onPageChanged(i),
            borderRadius: BorderRadius.circular(6),
            child: Container(
              width: 32,
              height: 32,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: isCurrent ? AppColor.primary : Colors.transparent,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: isCurrent ? AppColor.primary : Colors.grey.withOpacity(0.3),
                ),
              ),
              child: Text(
                '$i',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
                  color: isCurrent ? Colors.white : Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ),
          ),
        ),
      );
    }
    return items;
  }
}
