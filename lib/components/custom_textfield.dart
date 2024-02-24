import 'package:flutter/material.dart';
import 'package:intl_phone_field/intl_phone_field.dart';


class CustomTextField extends StatefulWidget {
  final TextEditingController controller;
  final String hintText;
  final bool? readOnly;
  final String? Function(String?)? validator;
  final TextInputType? keyboardType;
  final VoidCallback? onTap;

  const CustomTextField({
    super.key,
    required this.controller,
    required this.hintText,
    this.validator,
    this.keyboardType,
    this.onTap,
    this.readOnly,
  });

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: size.width * 0.01, vertical: size.height * 0.009),
      child: TextFormField(
        readOnly: widget.readOnly??false,
        onTap: widget.onTap,
        keyboardType: widget.keyboardType,
        validator: widget.validator ??
            (value) {
              if (value == null || value.isEmpty) {
                return 'Lütfen bir ${widget.hintText} girin';
              }
              return null;
            },
        style: const TextStyle(color: Color(0xfffcfcfc)),
        controller: widget.controller,
        decoration: InputDecoration(
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(size.width * 0.02)),
              borderSide: const BorderSide(color: Colors.white),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(size.width * 0.02)),
              borderSide: const BorderSide(color: Colors.orange),
            ),
            fillColor: Colors.transparent,
            filled: true,
            hintText: widget.hintText,
            hintStyle: const TextStyle(color: Color(0xfffcfcfc), fontWeight: FontWeight.w300)),
      ),
    );
  }
}

class PhoneTypeField extends StatelessWidget {
  final String hintText;
  final TextEditingController controller;
  final bool? readOnly;

  const PhoneTypeField({
    super.key,
    required this.hintText,
    required this.controller,
    this.readOnly,
  });

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: size.width * 0.01, vertical: size.height * 0.009),
      child: IntlPhoneField(
        style: const TextStyle(
          color: Colors.white,
        ),
        dropdownTextStyle: const TextStyle(
          color: Colors.white,
        ),
        controller: controller,
        dropdownIcon: const Icon(Icons.arrow_drop_down, color: Colors.white),
        decoration: InputDecoration(
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(size.width * 0.02)),
            borderSide: const BorderSide(color: Colors.white),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(size.width * 0.02)),
            borderSide: const BorderSide(color: Colors.orange),
          ),
          fillColor: Colors.transparent,
          filled: true,
          counterStyle: const TextStyle(color: Colors.white),
          hintText: hintText,
          hintStyle: const TextStyle(color: Color(0xfffcfcfc), fontWeight: FontWeight.w300),
        ),
        initialCountryCode: 'TR',
        onSaved: (phone) {
          if (phone != null) {
            final formattedPhone = '+${phone.countryCode}${phone.number}';
            controller.text = formattedPhone;
          }
        },
        onChanged: (phone) {},
      ),
    );
  }
}

class BloodTypeDropdown extends StatefulWidget {
  final TextEditingController controller;
  final String hintText;
  final String? Function(String?)? valid;
  final bool? readOnly;

  const BloodTypeDropdown({super.key, required this.controller, required this.hintText, this.valid, this.readOnly});

  @override
  _BloodTypeDropdownState createState() => _BloodTypeDropdownState();
}

class _BloodTypeDropdownState extends State<BloodTypeDropdown> {
  String? _selectedBloodType;

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: size.width * 0.01, vertical: size.height * 0.009),
      child: Container(
        height: 65,
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(size.width * 0.02),
          color: Colors.transparent,
          border: Border.all(color: Colors.white),
        ),
        child: Theme(
          data: Theme.of(context).copyWith(
            canvasColor: const Color(0xff87D793),
          ),
          child: DropdownButtonFormField<String>(
            menuMaxHeight: 200,
            validator: widget.valid ??
                (value) {
                  if (value == null || value.isEmpty) {
                    return 'Lütfen bir ${widget.hintText} girin';
                  }
                  return null;
                },
            icon: const Icon(Icons.arrow_drop_down, color: Colors.white),
            decoration: InputDecoration(
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              fillColor: Colors.transparent,
              filled: true,
              hintText: widget.hintText,
              hintStyle: const TextStyle(color: Color(0xfffcfcfc), fontWeight: FontWeight.w300),
            ),
            value: _selectedBloodType,
            onChanged: (String? newValue) {
              setState(() {
                _selectedBloodType = newValue;
                widget.controller.text = newValue ?? '';
              });
            },
            items: <String>["0 RH(+)", "0 RH(-)", "A RH(+)", "A RH(-)", "B RH(+)", "B RH(-)", "AB RH(+)", "AB RH(-)"]
                .map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(
                  value,
                  style: const TextStyle(color: Colors.white),
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}
