import 'package:flutter/material.dart';

class CustomInputField extends StatefulWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final FormFieldValidator<String>? validator;
  final bool isPassword;
  final TextInputType keyboardType;
  final IconData? prefixIcon;

  const CustomInputField({
    super.key,
    required this.controller,
    required this.label,
    this.hint = '',
    this.validator,
    this.isPassword = false,
    this.keyboardType = TextInputType.text,
    this.prefixIcon,
  });

  @override
  State<CustomInputField> createState() => _CustomInputFieldState();
}

class _CustomInputFieldState extends State<CustomInputField> {
  late bool _isObscure;

  @override
  void initState() {
    super.initState();
    _isObscure = widget.isPassword;
  }

  @override
  Widget build(BuildContext context) {
    final inputBorder = OutlineInputBorder(
      borderRadius: const BorderRadius.all(Radius.circular(10)),
      borderSide: const BorderSide(color: Colors.black54, width: 1.5),
    );
    
    final focusedInputBorderStyle = OutlineInputBorder(
      borderRadius: const BorderRadius.all(Radius.circular(10)),
      borderSide: BorderSide(color: Theme.of(context).primaryColor, width: 2.0),
    );

    return TextFormField(
      controller: widget.controller,
      obscureText: _isObscure, 
      keyboardType: widget.keyboardType,
      validator: widget.validator,
      
      decoration: InputDecoration(
        labelText: widget.label,
        hintText: widget.hint.isEmpty && widget.isPassword 
            ? 'Masukkan kata sandi Anda'
            : widget.hint,
        
        prefixIcon: widget.prefixIcon != null 
            ? Icon(widget.prefixIcon, color: Theme.of(context).primaryColor) 
            : null,
        
        suffixIcon: widget.isPassword
            ? IconButton(
                icon: Icon(
                  _isObscure ? Icons.visibility_off : Icons.visibility,
                  color: Colors.black54,
                ),
                onPressed: () {
                  setState(() {
                    _isObscure = !_isObscure;
                  });
                },
              )
            : null,
            
        border: inputBorder, 
        enabledBorder: inputBorder,
        focusedBorder: focusedInputBorderStyle,

        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
      ),
    );
  }
}