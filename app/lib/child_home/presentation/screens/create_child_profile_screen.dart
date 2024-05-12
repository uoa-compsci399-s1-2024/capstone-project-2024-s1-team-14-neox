import 'package:capstone_project_2024_s1_team_14_neox/child_home/cubit/child_device_cubit.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../cubit/all_child_profile_cubit.dart';

class CreateChildProfileScreen extends StatefulWidget {
  final bool editing;
  const CreateChildProfileScreen({super.key, required this.editing});

  @override
  State<CreateChildProfileScreen> createState() =>
      _CreateChildProfileScreenState();
}

class _CreateChildProfileScreenState extends State<CreateChildProfileScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _dobController = TextEditingController();
  final TextEditingController _authCodeController = TextEditingController();
  String _selectedGender = "";
  bool _unpair = true;

  @override
  void initState() {
    super.initState();

    if (widget.editing) {
      ChildDeviceState state = context.read<ChildDeviceCubit>().state;
      _nameController.text = state.childName;
      _dobController.text = DateFormat('yyyy-MM-dd').format(state.birthDate);
      _selectedGender = state.gender;
      _authCodeController.text = state.authorisationCode;
      _unpair = state.deviceRemoteId.isEmpty;
    }
  }

  @override
  Widget build(BuildContext context) {
    ChildDeviceState? state = widget.editing ? context.read<ChildDeviceCubit>().state : null;
    AllChildProfileCubit allChildProfileCubit = context.read<AllChildProfileCubit>();

    void onDateTapped() async {
      DateTime? pickedDate = await showDatePicker(
        context: context,
        initialDate: widget.editing ? state!.birthDate : DateTime.now(),
        firstDate: DateTime(1900),
        lastDate: DateTime.now(),
      );
      if (pickedDate != null) {
        String formattedDate = DateFormat('yyyy-MM-dd').format(pickedDate);
        setState(() {
          _dobController.text = formattedDate;
        });
      }
    }

    void onGenderSelected(String? value) {
      setState(() {
        _selectedGender = value!;
      });
    }

    void onUnpairPressed() {
      setState(() {
        _authCodeController.text = "";
        _unpair = true;
      });
    }

    void onDeletePressed() async {
      showDialog(
        context: context,
        builder: (innerContext) => AlertDialog(
          title: const Text("Delete profile"),
          content: const Text("Are you sure you want to delete this profile?\nAll associated data will be deleted and cannot be recovered."),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(innerContext),
              child: const Text("Cancel")
            ),
            TextButton(
              onPressed: () {
                context.read<AllChildProfileCubit>().deleteChildProfile(context.read<ChildDeviceCubit>().state.childId);
                Navigator.pop(innerContext);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                  content: Text('The profile has been deleted'),
                  duration: Duration(seconds: 2),
                  backgroundColor: Colors.lightBlue,
                ));
              },
              child: const Text("Delete")
            ),
          ],
        ),
      );
    }

    void onCancelPressed() {
      Navigator.of(context).pop();
    }

    void onSavePressed() async {
      NavigatorState navigator = Navigator.of(context);

      String name = _nameController.text.trim();
      String dob = _dobController.text.trim();
      String auth = _authCodeController.text.trim();

      if ((name.isEmpty || dob.isEmpty || _selectedGender.isEmpty) || (!_unpair && auth.isEmpty)) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Please fill out all fields'),
          duration: Duration(seconds: 2),
          backgroundColor: Colors.grey,
        ));
        return;
      } else if (!_unpair && auth.length != 10) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('The device authentication code must be 10 digits long'),
          duration: Duration(seconds: 2),
          backgroundColor: Colors.grey,
        ));
        return;
      }

      if (_unpair) {
        await allChildProfileCubit.updateDeviceRemoteId(
          childId: state!.childId,
          deviceRemoteId: "",
        );
      }

      await allChildProfileCubit.updateChildProfile(
        state!.childId,
        name,
        DateTime.parse(dob),
        _selectedGender,
        auth,
      );
      navigator.pop();
    }

    void onAddChildPressed() {
      String name = _nameController.text.trim();
      String dob = _dobController.text.trim();

      if (name.isEmpty || dob.isEmpty || _selectedGender.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Please fill out all fields'),
          duration: Duration(seconds: 2),
          backgroundColor: Colors.grey,
        ));
        return;
      }

      allChildProfileCubit.createChildProfile(
        _nameController.text.trim(),
        DateTime.parse(dob),
        _selectedGender,
      );
      Navigator.of(context).pop();
    }

    // Create fields

    const List<String> genders = [
      "",
      "male",
      "female",
      "other",
    ];
    const List<String> fields = [
      "Name",
      "Date of birth",
      "Gender",
      "Paired device ID",
      "Device authentication code",
    ];

    List<Widget> body = [
      TextField(
        controller: _nameController,
      ),
      TextField(
        controller: _dobController,
        readOnly: true,
        onTap: onDateTapped,
      ),
      DropdownButtonFormField(
        value: _selectedGender,
        items: genders
          .map((gender) => DropdownMenuItem(
            value: gender,
            child: Text(gender.isEmpty ? "" : (gender[0].toUpperCase() + gender.substring(1))))
          )
          .toList(),
        onChanged: onGenderSelected,
      ),
    ];

    if (widget.editing) {
      body.add(Row(
        children: [
          Text(
            _unpair ? "Not paired" : state!.deviceRemoteId,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          const Spacer(),
          ElevatedButton(
            onPressed: _unpair ? null : onUnpairPressed,
            child: const Text("Unpair"),
          ),
        ],
      ));

      body.add(TextField(
        controller: _authCodeController,
        enabled: !_unpair,
      ));
    }

    // Format each field
    for (int i = 0; i < body.length; i++) {
      body[i] = Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(fields[i]),
            body[i],
          ],
        ),
      );
    }

    // Create buttons
    List<Widget> buttons;
    if (widget.editing) {
      buttons = [
        ElevatedButton(
          onPressed: onDeletePressed,
          child: const Text('Delete'),
        ),
        const Spacer(),
        ElevatedButton(
          onPressed: onCancelPressed,
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: onSavePressed,
          child: const Text('Save'),
        ),
      ];
    } else {
      buttons = [
        ElevatedButton(
          onPressed: onAddChildPressed,
          child: const Text('Add child'),
        ),
      ];
    }

    // Format each button
    for (int i = 0; i < buttons.length; i++) {
      if (buttons[i] is! Spacer) {
        buttons[i] = Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
          child: buttons[i],
        );
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.editing ? "Edit profile" : "Add profile"),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ...body,
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: buttons,
            ),
          ),
        ],
      ),
    );
  }
}
