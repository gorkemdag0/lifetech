import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../components/custom_textfield.dart';
import '../services/auth_page.dart';
import 'homepage.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _formKey1 = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _surnameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _tcController = TextEditingController();
  final _bloodGroupController = TextEditingController();
  final _chronicDiseaseController = TextEditingController();
  final _medicationController = TextEditingController();

  final _relativeNameSurname = TextEditingController();
  final _relativePhone = TextEditingController();
  final _relativeDegree = TextEditingController();
  final TextEditingController _otpContoller = TextEditingController();

  @override
  void initState() {
    super.initState();
  }


  Future<void> _saveUserData(String uid) async {
    Map<String, dynamic> userData = {
      'name': _nameController.text,
      'surname': _surnameController.text,
      'phone': _phoneController.text,
      'tc': _tcController.text,
      'bloodGroup': _bloodGroupController.text,
      'chronicDisease': _chronicDiseaseController.text,
      'medication': _medicationController.text,
    };


    await FirebaseFirestore.instance.collection('users').doc(uid).set(userData);
    Map<String, dynamic> relativeData = {
      'name': _relativeNameSurname.text,
      'phone': _relativePhone.text,
      'degree': _relativeDegree.text,
    };


    await FirebaseFirestore.instance.collection('relatives').doc(uid).set(relativeData);
    _formKey.currentState?.reset();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Kayıt başarıyla tamamlandı.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    return Scaffold(
      body: Container(
        width: size.width,
        height: size.height,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue, Colors.green],
          ),
        ),
        child: SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.all(size.width * 0.05),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                       SizedBox(
                        height: size.height * 0.04,
                      ),
                      const Text("Kullanıcı Kayıt Formu",
                          style: TextStyle(color: Colors.white, fontSize: 30, fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center),
                       SizedBox(
                        height: size.height * 0.022,
                      ),
                      CustomTextField(
                        controller: _nameController,
                        hintText: "İsim",
                        keyboardType: TextInputType.text,
                      ),
                      CustomTextField(
                        controller: _surnameController,
                        hintText: "Soyisim",
                        keyboardType: TextInputType.text,
                      ),
                      PhoneTypeField(hintText: "Telefon", controller: _phoneController),
                      CustomTextField(
                          controller: _tcController, hintText: "TC Kimlik No", keyboardType: TextInputType.number),
                      BloodTypeDropdown(
                        controller: _bloodGroupController,
                        hintText: 'Kan Grubu',
                      ),
                      CustomTextField(
                          controller: _chronicDiseaseController,
                          hintText: 'Kronik Rahatsızlık',
                          validator: (value) {
                            return null;
                          }),
                      CustomTextField(
                          controller: _medicationController,
                          hintText: 'Kullanılan İlaçlar',
                          validator: (value) {
                            return null;
                          }),
                       SizedBox(height: size.height * 0.02,),
                      const Text("Yakın Bilgileri",
                          style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                          textAlign: TextAlign.start),
                      CustomTextField(
                        controller: _relativeNameSurname,
                        hintText: "Yakın İsim Soyisim",
                        keyboardType: TextInputType.text,
                      ),
                      PhoneTypeField(hintText: "Telefon", controller: _relativePhone),
                      CustomTextField(

                        controller: _relativeDegree,
                        hintText: "Yakınlık Derecesi",
                        keyboardType: TextInputType.text,
                      ),

                      ElevatedButton(
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            AuthService.sentOtp(
                                phone: _phoneController.text,
                                errorStep: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                                  content: Text(
                                    "SMS gönderilemedi",
                                    style: TextStyle(color: Colors.white),
                                  ),
                                  backgroundColor: Colors.red,
                                )),
                                nextStep: () {
                                  showDialog(
                                      context: context,
                                      builder: (context) => AlertDialog(
                                        title: const Text("SMS Doğrulama"),
                                        content: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            const Text("6 Haneli Kod"),
                                            const SizedBox(
                                              height: 12,
                                            ),
                                            Form(
                                              key: _formKey1,
                                              child: TextFormField(
                                                keyboardType: TextInputType.number,
                                                controller: _otpContoller,
                                                decoration: InputDecoration(
                                                    labelText: "Kodu Giriniz",
                                                    border:
                                                    OutlineInputBorder(borderRadius: BorderRadius.circular(32))),
                                                validator: (value) {
                                                  if (value!.length != 6) return "Geçersiz Kod";
                                                  return null;
                                                },
                                              ),
                                            ),
                                          ],
                                        ),
                                        actions: [
                                          TextButton(
                                              onPressed: () {
                                                if (_formKey1.currentState!.validate()) {
                                                  AuthService.loginWithOtp(otp: _otpContoller.text).then((value) {
                                                    if (value == "Success") {
                                                      _saveUserData(FirebaseAuth.instance.currentUser!.uid);
                                                      Navigator.pop(context);
                                                      Navigator.pushReplacement(context,
                                                          MaterialPageRoute(builder: (context) => const HomePage()));
                                                    } else {
                                                      Navigator.pop(context);
                                                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                                        content: Text(
                                                          value,
                                                          style: const TextStyle(color: Colors.white),
                                                        ),
                                                        backgroundColor: Colors.red,
                                                      ));
                                                    }
                                                  });
                                                }
                                              },
                                              child: const Text("Gönder"))
                                        ],
                                      ));
                                });
                          }
                        },
                        style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xff57C195), foregroundColor: Colors.white),
                        child: const Text("Kayıt Ol", style: TextStyle(fontSize: 18),),
                      ),
                    ],
                  ),
                ),
              ),
            ),
      ),
    );
  }
}
