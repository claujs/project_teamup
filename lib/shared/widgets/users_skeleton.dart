import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class UsersSkeleton extends StatelessWidget {
  final int itemCount;
  final bool isGridView;

  const UsersSkeleton({super.key, this.itemCount = 6, this.isGridView = false});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      enabled: true,
      child: isGridView ? _buildGrid() : _buildList(),
    );
  }

  Widget _buildGrid() {
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.75,
      ),
      itemCount: itemCount,
      itemBuilder: (context, index) => _buildGridItem(),
    );
  }

  Widget _buildList() {
    return ListView.builder(
      itemCount: itemCount,
      itemBuilder: (context, index) => _buildListItem(),
    );
  }

  Widget _buildGridItem() {
    return Card(
      child: Column(
        children: [
          const CircleAvatar(backgroundColor: Colors.white, radius: 40),
          const SizedBox(height: 12),
          Container(
            width: 100,
            height: 16,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(height: 8),
          Container(
            width: 120,
            height: 14,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildListItem() {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: const CircleAvatar(backgroundColor: Colors.white, radius: 20),
        title: Container(
          width: double.infinity,
          height: 16,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Container(
            width: 150,
            height: 14,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ),
      ),
    );
  }
}
