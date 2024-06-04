import 'package:flutter_riverpod/flutter_riverpod.dart';

class FormData{
  String? error;
  String inputField;

  FormData({
    required this.inputField,
    this.error
  });

  FormData copyWith({String? newError}){
    return FormData(
        inputField: inputField,
        error: newError
    );
  }
}

class FormDataNotifier extends StateNotifier<FormData>{
  FormDataNotifier({ required FormData initialFormState}) : super(initialFormState);

  bool validate(String input){
    if(input.isEmpty){
      state = state.copyWith(newError: "Field cannot be empty");
      return true;
    }else{
      state = state.copyWith(newError: null);
      return false;
    }
  }

  updateError(String? newError){
    state = state.copyWith(newError: newError);
  }
}

final emailFieldNotifierProvider = StateNotifierProvider<FormDataNotifier, FormData>((ref) {
  return FormDataNotifier(initialFormState: FormData(inputField: "email", error: null));
},);

final passwordFieldNotifierProvider = StateNotifierProvider<FormDataNotifier, FormData>((ref) {
  return FormDataNotifier(initialFormState: FormData(inputField: "password", error: null));
},);

final nameFieldNotifierProvider = StateNotifierProvider<FormDataNotifier, FormData>((ref) {
  return FormDataNotifier(initialFormState: FormData(inputField: "name", error: null));
},);