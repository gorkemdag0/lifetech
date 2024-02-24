import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../components/custom_textfield.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late User _currentUser;
  late DocumentSnapshot _userData;
  late DocumentSnapshot _relativeData;

  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _surnameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _tcController = TextEditingController();
  final _bloodGroupController = TextEditingController();
  final _chronicDiseaseController = TextEditingController();
  final _medicationController = TextEditingController();

  final _relativeNameSurnameController = TextEditingController();
  final _relativePhoneController = TextEditingController();
  final _relativeDegreeController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _currentUser = FirebaseAuth.instance.currentUser!;
    _loadUserData();
    _loadRelativeData();
  }

  Future<void> _loadUserData() async {
    _userData = await FirebaseFirestore.instance.collection('users').doc(_currentUser.uid).get();
    setState(() {
      _nameController.text = _userData['name'];
      _surnameController.text = _userData['surname'];
      _phoneController.text = _userData['phone'];
      _tcController.text = _userData['tc'];
      _bloodGroupController.text = _userData['bloodGroup'];
      _chronicDiseaseController.text = _userData['chronicDisease'];
      _medicationController.text = _userData['medication'];
    });
  }

  Future<void> _loadRelativeData() async {
    _relativeData = await FirebaseFirestore.instance.collection('relatives').doc(_currentUser.uid).get();
    setState(() {
      _relativeNameSurnameController.text = _relativeData['name'];
      _relativePhoneController.text = _relativeData['phone'];
      _relativeDegreeController.text = _relativeData['degree'];
    });
  }

  Widget _buildCustomTextFieldWithLabel(String label, TextEditingController controller, Widget customField,
      {bool readOnly = true}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 5,),
        Padding(
          padding: const EdgeInsets.only(left: 10.0),
          child: Text(
            label,
            style: const TextStyle(
                fontSize: 15,
                fontStyle: FontStyle.italic,
                color: Colors.white
            ),
          ),
        ),
        customField,
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil'),
      ),
      body: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue, Colors.green],
          ),
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'Kullanıcı Bilgileri',
                    style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold, color: Color(0xFFFDFDB3)),
                  ),
                  _buildCustomTextFieldWithLabel(
                      "İsim",
                      _nameController,
                      CustomTextField(
                        controller: _nameController,
                        hintText: "İsim",
                        readOnly: true,
                      )),
                  _buildCustomTextFieldWithLabel(
                      "Soyisim",
                      _surnameController,
                      CustomTextField(
                        controller: _surnameController,
                        hintText: "Soyisim",
                        readOnly: true,
                      )),
                  _buildCustomTextFieldWithLabel(
                      "TC Kimlik No",
                      _tcController,
                      CustomTextField(
                        controller: _tcController,
                        hintText: "TC Kimlik No",
                        readOnly: true,
                      )),
                  _buildCustomTextFieldWithLabel(
                      "Telefon",
                      _phoneController,
                      PhoneTypeField(
                        controller: _phoneController,
                        hintText: "Telefon",
                        readOnly: false,
                      )),
                  _buildCustomTextFieldWithLabel(
                      "Kan Grubu",
                      _bloodGroupController,
                      BloodTypeDropdown(
                        controller: _bloodGroupController,
                        hintText: "Kan Grubu",
                      ),
                      readOnly: false),
                  _buildCustomTextFieldWithLabel(
                      "Kronik Rahatsızlık (Opsiyonel)",
                      _chronicDiseaseController,
                      CustomTextField(
                        controller: _chronicDiseaseController,
                        hintText: "Kronik Rahatsızlık (Opsiyonel)",
                        readOnly: false,
                        validator: (value) {},
                      )),
                  _buildCustomTextFieldWithLabel(
                      "Kullanılan İlaçlar (Opsiyonel)",
                      _medicationController,
                      CustomTextField(
                        controller: _medicationController,
                        hintText: "Kullanılan İlaçlar (Opsiyonel)",
                        readOnly: false,
                        validator: (value) {},
                      )),
                  const SizedBox(height: 20),
                  const Text(
                    'Yakın Bilgileri',
                    style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold, color: Color(0xFFFDFDB3)),
                  ),
                  _buildCustomTextFieldWithLabel(
                      "Yakın İsim Soyisim",
                      _relativeNameSurnameController,
                      CustomTextField(
                        controller: _relativeNameSurnameController,
                        hintText: "Yakın İsim Soyisim",
                        readOnly: false,
                        validator: (value) {},
                      )),
                  _buildCustomTextFieldWithLabel(
                      "Yakınlık Derecesi",
                      _relativeDegreeController,
                      CustomTextField(
                        controller: _relativeDegreeController,
                        hintText: "Yakınlık Derecesi",
                        readOnly: false,
                        validator: (value) {},
                      )),
                  _buildCustomTextFieldWithLabel(
                      "Yakın Telefon",
                      _relativePhoneController,
                      PhoneTypeField(
                        controller: _relativePhoneController,
                        hintText: "Yakın Telefon",
                        readOnly: false,
                      )),

                  ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        _saveUserData();
                        _saveRelativeData();
                      }
                    },
                    child: const Text("Bilgileri Kaydet"),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _saveUserData() async {
    try {
      await FirebaseFirestore.instance.collection('users').doc(_currentUser.uid).update({
        'phone': _phoneController.text,
        'tc': _tcController.text,
        'bloodGroup': _bloodGroupController.text,
        'chronicDisease': _chronicDiseaseController.text,
        'medication': _medicationController.text,
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Bilgiler başarıyla güncellendi.'),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Bilgiler güncellenirken bir hata oluştu.'),
        ),
      );
    }
  }

  Future<void> _saveRelativeData() async {
    try {
      await FirebaseFirestore.instance.collection('relatives').doc(_currentUser.uid).update({
        'name': _relativeNameSurnameController.text,
        'phone': _relativePhoneController.text,
        'degree': _relativeDegreeController.text,
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Yakın bilgileri başarıyla güncellendi.'),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Yakın bilgileri güncellenirken bir hata oluştu.'),
        ),
      );
    }
  }
}
