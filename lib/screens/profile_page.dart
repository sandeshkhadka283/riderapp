import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _vehicleController = TextEditingController();
  File? _profileImage;
  File? _licenseImage;

  String _status = "not_submitted"; // not_submitted, under_review, approved

  Future<void> _pickImage(bool isProfile) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );
    if (pickedFile != null) {
      setState(() {
        if (isProfile) {
          _profileImage = File(pickedFile.path);
        } else {
          _licenseImage = File(pickedFile.path);
        }
      });
    }
  }

  void _submitProfile() {
    if (_formKey.currentState!.validate()) {
      if (_profileImage == null || _licenseImage == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Please upload both images")),
        );
        return;
      }

      setState(() {
        _status = "under_review";
      });

      Future.delayed(const Duration(seconds: 3), () {
        setState(() {
          _status = "approved";
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text("Rider Profile"),
        centerTitle: true,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              _buildProfileHeader(),
              const SizedBox(height: 20),
              _status == "approved" ? _buildProfileView() : _buildForm(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Colors.redAccent, Colors.deepOrangeAccent],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 4)),
        ],
      ),
      child: Column(
        children: [
          Stack(
            children: [
              CircleAvatar(
                radius: 55,
                backgroundColor: Colors.white,
                backgroundImage: _profileImage != null
                    ? FileImage(_profileImage!)
                    : null,
                child: _profileImage == null
                    ? const Icon(Icons.person, size: 55, color: Colors.grey)
                    : null,
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: GestureDetector(
                  onTap: () => _pickImage(true),
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.camera_alt,
                      color: Colors.redAccent,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            _nameController.text.isEmpty ? "Your Name" : _nameController.text,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _status == "approved"
                ? "Verified"
                : _status == "under_review"
                ? "Under Review"
                : "Unverified",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: _status == "approved"
                  ? Colors.greenAccent
                  : _status == "under_review"
                  ? Colors.yellowAccent
                  : Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildForm() {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          const SizedBox(height: 20),
          GestureDetector(
            onTap: () => _pickImage(false),
            child: Container(
              height: 150,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 6,
                    offset: Offset(0, 3),
                  ),
                ],
                image: _licenseImage != null
                    ? DecorationImage(
                        image: FileImage(_licenseImage!),
                        fit: BoxFit.cover,
                      )
                    : null,
              ),
              child: _licenseImage == null
                  ? const Center(
                      child: Text(
                        "Tap to upload Vehicle License",
                        style: TextStyle(color: Colors.grey),
                      ),
                    )
                  : null,
            ),
          ),
          const SizedBox(height: 20),
          TextFormField(
            controller: _nameController,
            decoration: InputDecoration(
              labelText: "Full Name",
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
              prefixIcon: const Icon(Icons.person),
            ),
            validator: (value) =>
                value == null || value.isEmpty ? "Enter your name" : null,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _vehicleController,
            decoration: InputDecoration(
              labelText: "Vehicle Info",
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
              prefixIcon: const Icon(Icons.directions_car),
            ),
            validator: (value) =>
                value == null || value.isEmpty ? "Enter vehicle info" : null,
          ),
          const SizedBox(height: 30),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: _submitProfile,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: const Text(
                "Submit Profile",
                style: TextStyle(fontSize: 18, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileView() {
    return Column(
      children: [
        const SizedBox(height: 20),
        _buildInfoCard(Icons.person, "Full Name", _nameController.text),
        const SizedBox(height: 12),
        _buildInfoCard(
          Icons.directions_car,
          "Vehicle Info",
          _vehicleController.text,
        ),
        const SizedBox(height: 12),
        Container(
          height: 200,
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            image: DecorationImage(
              image: FileImage(_licenseImage!),
              fit: BoxFit.cover,
            ),
            boxShadow: const [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 6,
                offset: Offset(0, 4),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildInfoCard(IconData icon, String title, String value) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 3,
      child: ListTile(
        leading: Icon(icon, color: Colors.redAccent),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(value),
      ),
    );
  }
}
