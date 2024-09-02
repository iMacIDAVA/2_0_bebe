import 'package:flutter/material.dart';
import 'package:sos_bebe_app/custom_picker/listPickerSosBebe.dart';

Future<String?> showPickerSOSBebeDialog({
  required BuildContext context,
  required String label,
  required List<String> items,
}) {
  return showDialog(
    context: context,
    builder: (BuildContext context) => ListPickerDialogSosBebe(
      label: label,
      items: items,
    ),
  );
}
