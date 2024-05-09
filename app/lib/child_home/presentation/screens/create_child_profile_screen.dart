import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../cubit/all_child_profile_cubit.dart';

class CreateChildProfileScreen extends StatefulWidget {
  const CreateChildProfileScreen({super.key});

  @override
  State<CreateChildProfileScreen> createState() =>
      _CreateChildProfileScreenState();
}

class _CreateChildProfileScreenState extends State<CreateChildProfileScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController dobController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Add Child Profile"),
      ),
      body: Column(
        children: [
          TextField(
            controller: nameController,
            decoration: const InputDecoration(hintText: "Name"),
          ),
          TextField(
            controller: dobController,
            decoration: const InputDecoration(hintText: "Date of Birth"),
            readOnly: true,
            onTap: () async {
              DateTime? pickedDate = await showDatePicker(
                context: context,
                initialDate: DateTime.now(),
                firstDate: DateTime(1990),
                lastDate: DateTime(2030),
              );
              if (pickedDate != null) {
                String formattedDate =
                    DateFormat('yyyy-MM-dd').format(pickedDate);
                setState(() {
                  dobController.text = formattedDate;
                });
              }
            },
          ),
          ElevatedButton(
            onPressed: () {
              context.read<AllChildProfileCubit>().createChildProfile(
                    nameController.text.trim(),
                    DateTime.parse(dobController.text.trim()),
                    "" // TODO: pass gender
                  );
              Navigator.of(context).pop();
            },
            child: const Text('Add child'),
          )
        ],
      ),
    );
  }
}
