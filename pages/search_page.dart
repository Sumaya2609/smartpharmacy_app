// lib/pages/search_page.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../controllers/firestore_stock_controller.dart';
import '../colors.dart';
import 'medicine_details_page.dart';

class SearchPage extends StatelessWidget {
  const SearchPage({super.key});

  @override
  Widget build(BuildContext context) {
    final stock = Get.find<FirestoreStockController>();
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        title: const Text('Search medicines'),
        backgroundColor: AppColors.bg,
        foregroundColor: AppColors.title,
        elevation: 0,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              autofocus: true,
              onChanged: (v) => stock.searchQuery.value = v,
              decoration: InputDecoration(
                hintText: 'Type medicine name...',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          if (user != null)
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // recent searches
                  Padding(
                    padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    child: const Text(
                      'Recent searches',
                      style:
                      TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                    ),
                  ),
                  SizedBox(
                    height: 40,
                    child: StreamBuilder(
                      stream:
                      stock.recentSearchesStream(user.uid),
                      builder: (context, snap) {
                        if (!snap.hasData || snap.data!.docs.isEmpty) {
                          return const SizedBox.shrink();
                        }
                        final docs = snap.data!.docs;

                        return ListView.separated(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          itemCount: docs.length,
                          itemBuilder: (_, i) {
                            final medId = docs[i]['medicineId'] as String;
                            final med = stock.medicines
                                .firstWhereOrNull((m) => m.id == medId);
                            if (med == null) return const SizedBox.shrink();

                            return ActionChip(
                              label: Text(med.name),
                              onPressed: () {
                                Get.to(() => MedicineDetailsPage(medicine: med));
                              },
                            );
                          },
                          separatorBuilder: (_, __) =>
                          const SizedBox(width: 8),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 8),
                  // search results
                  Expanded(
                    child: Obx(() {
                      final q = stock.searchQuery.value;
                      final results = stock.filteredMedicines;

                      if (q.isNotEmpty && results.isEmpty) {
                        return const Center(
                          child: Text(
                            'No medicines found for this search.',
                            style: TextStyle(color: Colors.red),
                          ),
                        );
                      }
                      if (results.isEmpty) {
                        return const Center(
                          child: Text('Type to search medicines'),
                        );
                      }

                      return ListView.builder(
                        itemCount: results.length,
                        itemBuilder: (_, i) {
                          final m = results[i];
                          return ListTile(
                            title: Text(m.name),
                            subtitle: Text(m.brand),
                            onTap: () async {
                              if (user != null) {
                                await stock.addRecentSearch(user.uid, m.id);
                              }
                              Get.to(() => MedicineDetailsPage(medicine: m));
                            },
                          );
                        },
                      );
                    }),
                  ),
                ],
              ),
            )
          else
            const Expanded(
              child: Center(
                child: Text('Login to see recent searches'),
              ),
            ),
        ],
      ),
    );
  }
}
