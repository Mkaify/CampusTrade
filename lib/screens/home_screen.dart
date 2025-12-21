import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Import Auth
import '../services/database_service.dart';
import 'profile_screen.dart';
import 'gemini_chat_screen.dart';
import 'product_detail_screen.dart';
import 'add_product_screen.dart';
import 'chat_list_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String searchQuery = "";
  String selectedCategory = "All";
  final List<String> categories = ["All", "Books", "Electronics", "Hostel", "Other"];

  @override
  Widget build(BuildContext context) {
    // Get current user to see their photo
    final User? user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text("CampusTrade"),
        actions: [
          // 1. AI Assistant
          IconButton(
            icon: const Icon(Icons.smart_toy),
            tooltip: "Ask AI Assistant",
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const GeminiChatScreen()),
              );
            },
          ),

          // 2. Inbox
          IconButton(
            icon: const Icon(Icons.message_outlined),
            tooltip: "My Messages",
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ChatListScreen()),
              );
            },
          ),

          // 3. PROFILE PICTURE (The Final Polish ✨)
          Padding(
            padding: const EdgeInsets.only(right: 12.0),
            child: GestureDetector(
              onTap: () async {
                // Wait for them to come back, then refresh to show new photo
                await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ProfileScreen()),
                );
                setState(() {});
              },
              child: CircleAvatar(
                radius: 16, // Size of the bubble
                backgroundColor: Colors.grey.shade200,
                backgroundImage: (user?.photoURL != null)
                    ? NetworkImage(user!.photoURL!)
                    : null,
                child: (user?.photoURL == null)
                    ? const Icon(Icons.person, size: 20, color: Colors.grey)
                    : null,
              ),
            ),
          ),
        ],

        // Search & Filter Section
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(120),
          child: Container(
            color: Colors.white,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: "Search items (e.g. Calculus)",
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      contentPadding: const EdgeInsets.symmetric(vertical: 0),
                      filled: true,
                      fillColor: Colors.grey[100],
                    ),
                    onChanged: (value) => setState(() => searchQuery = value.toLowerCase()),
                  ),
                ),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  child: Row(
                    children: categories.map((cat) {
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ChoiceChip(
                          label: Text(cat),
                          selected: selectedCategory == cat,
                          selectedColor: Colors.blue.shade100,
                          onSelected: (bool selected) {
                            if (selected) setState(() => selectedCategory = cat);
                          },
                        ),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 5),
              ],
            ),
          ),
        ),
      ),

      // Product List
      body: StreamBuilder<QuerySnapshot>(
        stream: DatabaseService().getProducts(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) return const Center(child: Text("Something went wrong!"));

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("No products found."));
          }

          var allDocs = snapshot.data!.docs;
          var filteredDocs = allDocs.where((doc) {
            var data = doc.data() as Map<String, dynamic>;
            String title = (data['title'] ?? '').toString().toLowerCase();
            String category = (data['category'] ?? 'Other').toString();

            bool matchesSearch = title.contains(searchQuery);
            bool matchesCategory = selectedCategory == "All" || category == selectedCategory;

            return matchesSearch && matchesCategory;
          }).toList();

          if (filteredDocs.isEmpty) return const Center(child: Text("No items match your search."));

          return ListView.builder(
            // ADD THIS LINE:
            physics: const BouncingScrollPhysics(),
            itemCount: filteredDocs.length,
            padding: const EdgeInsets.only(top: 10),
            itemBuilder: (context, index) {
              var data = filteredDocs[index].data() as Map<String, dynamic>;
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                elevation: 2,
                child: ListTile(
                  contentPadding: const EdgeInsets.all(8),
                  leading: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      data['imageUrl'] ?? 'https://via.placeholder.com/150',
                      width: 60, height: 60, fit: BoxFit.cover,
                      errorBuilder: (c, e, s) => const Icon(Icons.broken_image, color: Colors.grey),
                    ),
                  ),
                  title: Text(data['title'] ?? 'No Title', style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text("PKR ${data['price']}", style: const TextStyle(color: Colors.green, fontWeight: FontWeight.w600)),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => ProductDetailScreen(productData: data)));
                  },
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => const AddProductScreen()));
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}