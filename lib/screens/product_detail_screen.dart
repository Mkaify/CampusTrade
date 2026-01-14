import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'chat_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ProductDetailScreen extends StatelessWidget {
  final Map<String, dynamic> productData;

  const ProductDetailScreen({super.key, required this.productData});

  // Function to open the Email App
  Future<void> _contactSeller(BuildContext context) async {
    final String email = productData['sellerEmail'] ?? '';
    final String title = productData['title'] ?? 'Item';

    if (email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Seller email not available.")),
      );
      return;
    }

    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: email,
      query: 'subject=CampusTrade Inquiry: $title&body=Hi, I am interested in buying "$title"...',
    );

    try {
      if (await canLaunchUrl(emailUri)) {
        await launchUrl(emailUri);
      } else {
        // Fallback for emulators or devices without email apps
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Could not launch email app.")),
          );
        }
      }
    } catch (e) {
      debugPrint("Error launching email: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    // 1. Get Current User
    final currentUser = FirebaseAuth.instance.currentUser;

    // Safely get data with fallbacks
    final String imageUrl = productData['imageUrl'] ?? '';
    final String title = productData['title'] ?? 'No Title';
    final String price = productData['price'].toString();
    final String description = productData['description'] ?? 'No description provided.';
    final String sellerEmail = productData['sellerEmail'] ?? 'Unknown Seller';

    return Scaffold(
      appBar: AppBar(title: const Text("Item Details")),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Hero Image
            imageUrl.isNotEmpty
                ? Image.network(
              imageUrl,
              width: double.infinity,
              height: 300,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) =>
                  Container(
                      height: 300,
                      color: Colors.grey[300],
                      child: const Center(child: Icon(Icons.broken_image, size: 50))
                  ),
            )
                : Container(
                height: 300,
                color: Colors.grey[300],
                child: const Center(child: Icon(Icons.image, size: 50))
            ),

            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 2. Title and Category Tag
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
                        ),
                      ),
                      // Optional: Show category if you have it
                      if (productData.containsKey('category'))
                        Chip(
                          label: Text(productData['category']),
                          backgroundColor: Colors.blue.shade50,
                        ),
                    ],
                  ),

                  const SizedBox(height: 5),

                  // 3. Price
                  Text(
                    "PKR $price",
                    style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w600,
                        color: Colors.green
                    ),
                  ),

                  const SizedBox(height: 20),
                  const Divider(),
                  const SizedBox(height: 10),

                  // 4. Description Section
                  const Text(
                    "Description",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    description,
                    style: TextStyle(fontSize: 16, color: Colors.grey[800], height: 1.4),
                  ),

                  const SizedBox(height: 30),

                  // 5. Seller Info Card
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: Row(
                      children: [
                        const CircleAvatar(
                          backgroundColor: Colors.blue,
                          child: Icon(Icons.person, color: Colors.white),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text("Seller", style: TextStyle(fontSize: 12, color: Colors.grey)),
                              Text(
                                sellerEmail,
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // --- THE FIX: Only show button if I am NOT the seller ---
                  if (currentUser?.email != sellerEmail)
                    Column(
                      children: [
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton.icon(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ChatScreen(receiverEmail: sellerEmail),
                                ),
                              );
                            },
                            icon: const Icon(Icons.chat),
                            label: const Text("Chat with Seller", style: TextStyle(fontSize: 16)),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: OutlinedButton.icon(
                            onPressed: () => _contactSeller(context),
                            icon: const Icon(Icons.email_outlined),
                            label: const Text("Email Seller", style: TextStyle(fontSize: 16)),
                            style: OutlinedButton.styleFrom(
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                          ),
                        ),
                      ],
                    ),

                  // Optional: You could show a "Manage Item" text if it IS their item
                  if (currentUser?.email == sellerEmail)
                    const Center(
                        child: Text(
                            "This is your item.",
                            style: TextStyle(color: Colors.grey, fontStyle: FontStyle.italic)
                        )
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}