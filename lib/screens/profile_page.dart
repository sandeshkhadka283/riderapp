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

  // -------------------- Image Picker --------------------
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

  // -------------------- Submit Profile --------------------
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

  // -------------------- Build UI --------------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
        elevation: 1,
        title: const Text(
          "Rider Profile",
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.black87),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildProfileHeader(), // -------------------- Header --------------------
            const SizedBox(height: 20),
            _status == "approved"
                ? _buildProfileView()
                : _buildForm(), // Form or View
          ],
        ),
      ),
    );
  }

  // ================== PROFILE HEADER ==================
  Widget _buildProfileHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Colors.greenAccent, Colors.green],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [
          BoxShadow(color: Colors.black26, blurRadius: 8, offset: Offset(0, 4)),
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
                      color: Colors.green,
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

  // ================== FORM ==================
  Widget _buildForm() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildUploadCard(
            title: "Upload Vehicle License",
            file: _licenseImage,
            onTap: () => _pickImage(false),
          ),
          const SizedBox(height: 20),
          _buildTextField(_nameController, "Full Name", Icons.person),
          const SizedBox(height: 16),
          _buildTextField(
            _vehicleController,
            "Vehicle Info",
            Icons.directions_car,
          ),
          const SizedBox(height: 30),
          ElevatedButton(
            onPressed: _submitProfile,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: const Text(
              "Submit Profile",
              style: TextStyle(fontSize: 18, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  // ================== PROFILE VIEW ==================
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
        _buildImageCard(_licenseImage!),
      ],
    );
  }

  // ================== HELPER WIDGETS ==================
  Widget _buildTextField(
    TextEditingController controller,
    String label,
    IconData icon,
  ) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: Colors.white,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
      ),
      validator: (value) =>
          value == null || value.isEmpty ? "Enter $label" : null,
    );
  }

  Widget _buildUploadCard({
    required String title,
    File? file,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 160,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 6,
              offset: Offset(0, 3),
            ),
          ],
          image: file != null
              ? DecorationImage(image: FileImage(file), fit: BoxFit.cover)
              : null,
        ),
        child: file == null
            ? Center(
                child: Text(
                  title,
                  style: TextStyle(color: Colors.grey[600], fontSize: 16),
                ),
              )
            : null,
      ),
    );
  }

  Widget _buildInfoCard(IconData icon, String title, String value) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      elevation: 4,
      child: ListTile(
        leading: Icon(icon, color: Colors.green),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(value),
      ),
    );
  }

  Widget _buildImageCard(File image) {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        image: DecorationImage(image: FileImage(image), fit: BoxFit.cover),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 4)),
        ],
      ),
    );
  }
}
