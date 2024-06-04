import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:news_app/utils/constants.dart';

final showPasswordProvider = StateProvider<bool>((ref) {
  return false;
},);

class TextInput extends ConsumerStatefulWidget {
  const TextInput({
    super.key,
    required this.text,
    required this.controller,
    required this.removeError,
    required this.error,
    required this.focusNode
  });

  final String text;
  final TextEditingController controller;
  final String? error;
  final Function removeError;
  final FocusNode focusNode;

  @override
  ConsumerState<TextInput> createState() => _TextInputState();
}

class _TextInputState extends ConsumerState<TextInput> {

  @override
  Widget build(BuildContext context) {
    bool showPassword = ref.watch(showPasswordProvider);
    return TextFormField(
      focusNode: widget.focusNode,
      autovalidateMode: widget.controller.text.isEmpty ? AutovalidateMode.disabled : AutovalidateMode.onUserInteraction,
      controller: widget.controller,
      onTapOutside: (event) {
        FocusScopeNode focusNode = FocusScope.of(context);
        if (!focusNode.hasPrimaryFocus) {
          focusNode.unfocus();
        }
      },
      obscureText: widget.text == "Password" && !showPassword ? true : false,
      onChanged: (value){
        if(widget.error != null)widget.removeError();
      },
      style : AppTheme.getStyle(
          color: Colors.black,
          fs: 16,
          fw: FontWeight.w200,
      ),
      decoration: InputDecoration(
        errorText: widget.error,
        labelText: widget.text,
        filled: true,
        fillColor: Colors.white,
        labelStyle: const TextStyle(
          color: Colors.black,
          fontFamily: 'Poppins',
          fontWeight: FontWeight.w500,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.only(left: 15),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide.none,
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide.none,
        ),
        errorStyle: const TextStyle(
            fontFamily: 'Poppins',
            fontSize: 14,
            fontWeight: FontWeight.w500,
        ),
        suffixIcon: widget.text == "Password"
            ? IconButton(
              onPressed: () => ref.read(showPasswordProvider.notifier).state = !showPassword,
              icon: showPassword
                  ? const Icon(Icons.visibility, size: 20,)
                  : const Icon(Icons.visibility_off, size: 20,),)
            : (widget.controller.text.isNotEmpty
                ? IconButton(
                  onPressed: (){
                    widget.controller.text = "";
                    widget.removeError();
                    },
                  icon: const Icon(Icons.close, size: 20,),
                )
                : null
        )
      )
    );
  }
}