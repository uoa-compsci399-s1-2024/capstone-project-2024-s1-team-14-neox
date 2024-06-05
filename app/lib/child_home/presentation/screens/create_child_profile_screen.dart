import 'package:capstone_project_2024_s1_team_14_neox/child_home/cubit/child_device_cubit.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
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
      _dobController.text = DateFormat('d MMMM yyyy').format(state.birthDate);
      _selectedGender = state.gender;
      _authCodeController.text = state.authorisationCode;
      _unpair = state.deviceRemoteId.isEmpty;
    }
  }

  @override
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.sizeOf(context);
    double screenWidth = screenSize.width;
    double screenHeight = screenSize.height;
    ChildDeviceState? state =
        widget.editing ? context.read<ChildDeviceCubit>().state : null;
    AllChildProfileCubit allChildProfileCubit =
        context.read<AllChildProfileCubit>();

    void onDateTapped() async {
      DateTime? pickedDate = await showDatePicker(
        context: context,
        initialDate: widget.editing ? state!.birthDate : DateTime.now(),
        firstDate: DateTime(1900),
        lastDate: DateTime.now(),
      );
      if (pickedDate != null) {
        String formattedDate = DateFormat('d MMMM yyyy').format(pickedDate);
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
          content: const Text(
              "Are you sure you want to delete this profile? All associated data will be deleted and cannot be recovered."),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(innerContext),
                child: const Text("Cancel")),
            TextButton(
                onPressed: () {
                  context.read<AllChildProfileCubit>().deleteChildProfile(
                      context.read<ChildDeviceCubit>().state.childId);
                  Navigator.pop(innerContext);
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: const Text('The profile has been deleted'),
                    duration: const Duration(seconds: 2),
                    backgroundColor: Theme.of(context).colorScheme.secondary,
                  ));
                },
                child: const Text("Delete")),
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

      if ((name.isEmpty || dob.isEmpty || _selectedGender.isEmpty) ||
          (!_unpair && auth.isEmpty)) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Please fill out all fields'),
          duration: Duration(seconds: 2),
          backgroundColor: Colors.grey,
        ));
        return;
      } else if (!_unpair && auth.length != 10) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content:
              Text('The device authentication code must be 10 digits long'),
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
        DateFormat('d MMMM yyyy').parse(dob),
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
        DateFormat('d MMMM yyyy').parse(dob),
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
      const SizedBox(height: 8),
      TextField(
        controller: _nameController,
        keyboardType: TextInputType.text,
        decoration: InputDecoration(
          labelText: "Name",
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(
              color: Theme.of(context).colorScheme.tertiary,
              width: 2,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(
              color: Theme.of(context).colorScheme.primary,
              width: 2,
            ),
          ),
          // prefixIcon: Icon(Icons.person),
        ),
      ),
      const SizedBox(
        height: 20,
      ),
      TextField(
        controller: _dobController,
        keyboardType: TextInputType.text,
        readOnly: true,
        onTap: onDateTapped,
        decoration: InputDecoration(
          labelText: "Date of birth",
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(
              color: Theme.of(context).colorScheme.tertiary,
              width: 2,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(
              color: Theme.of(context).colorScheme.primary,
              width: 2,
            ),
          ),
          // prefixIcon: Icon(Icons.person),
        ),
      ),
      // TextField(
      //   controller: _nameController,
      // ),
      // TextField(
      //   controller: _dobController,
      //   readOnly: true,
      //   onTap: onDateTapped,
      // ),
      const SizedBox(
        height: 20,
      ),
      DropdownButtonFormField(
        value: _selectedGender,
        icon: const Icon(
          Icons.keyboard_arrow_down,
          color: Colors.black,
        ),
        isExpanded: true,
        items: genders
            .map((gender) => DropdownMenuItem(
                value: gender,
                child: Text(gender.isEmpty
                    ? ""
                    : (gender[0].toUpperCase() + gender.substring(1)))))
            .toList(),
        onChanged: onGenderSelected,
        elevation: 2,
        borderRadius: BorderRadius.circular(16),
        decoration: InputDecoration(
          labelText: "Gender",
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(
              color: Theme.of(context).colorScheme.tertiary,
              width: 2,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(
              color: Theme.of(context).colorScheme.primary,
              width: 2,
            ),
          ),
          // prefixIcon: Icon(Icons.person),
        ),
      ),
      const SizedBox(
        height: 20,
      ),
    ];

    if (widget.editing) {
      body.addAll([
        Row(
          children: [
            Expanded(
              child: TextField(
                enabled: !_unpair,
                controller: TextEditingController.fromValue(TextEditingValue(
                  text: _unpair ? "Not paired" : state!.deviceRemoteId,
                )),
                readOnly: true,
                decoration: InputDecoration(
                  labelText: "Device remote ID",
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(
                      color: Theme.of(context).colorScheme.tertiary,
                      width: 2,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(
                      color: Theme.of(context).colorScheme.primary,
                      width: 2,
                    ),
                  ),
                  // prefixIcon: Icon(Icons.person),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 12),
              child: ElevatedButton(
                onPressed: _unpair ? null : onUnpairPressed,
                child: const Text("Unpair"),
              ),
            ),
          ],
        ),
        const SizedBox(
          height: 20,
        ),
        TextField(
          enabled: !_unpair,
          controller: _authCodeController,
          decoration: InputDecoration(
            labelText: "Device authentication code",
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: Theme.of(context).colorScheme.tertiary,
                width: 2,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: Theme.of(context).colorScheme.primary,
                width: 2,
              ),
            ),
            // prefixIcon: Icon(Icons.person),
          ),
        ),
        const SizedBox(
          height: 20,
        ),
      ]);
    }

    // Create buttons
    List<Widget> buttons;
    if (widget.editing) {
      buttons = [
        SizedBox(
          width: screenWidth,
          height: 40,
          child: FilledButton(
            style: ButtonStyle(
                shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                    RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ))),
            onPressed: onSavePressed,
            child: const Text(
              'Save',
              style: TextStyle(fontSize: 20),
            ),
          ),
        ),
        const SizedBox(
          height: 10,
        ),
        SizedBox(
          width: screenWidth,
          height: 40,
          child: OutlinedButton(
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: Theme.of(context).colorScheme.primary),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: onCancelPressed,
            child: const Text(
              'Cancel',
              style: TextStyle(
                fontSize: 20,
                // color: Colors.red,
              ),
            ),
          ),
        ),
        const SizedBox(
          height: 40,
        ),
        SizedBox(
          width: screenWidth,
          height: 40,
          child: OutlinedButton(
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Colors.red),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: onDeletePressed,
            child: const Text(
              'Delete child',
              style: TextStyle(
                fontSize: 20,
                color: Colors.red,
              ),
            ),
          ),
        ),
      ];
    } else {
      buttons = [
        const SizedBox(
          height: 40,
        ),
        SizedBox(
          width: screenWidth,
          height: 40,
          child: FilledButton(
            style: ButtonStyle(
                shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                    RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ))),
            onPressed: onAddChildPressed,
            child: const Text(
              'Add',
              style: TextStyle(fontSize: 20),
            ),
          ),
        ),
      ];
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.editing ? "Edit profile" : "Add profile"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            // crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ...body,
              ...buttons,
            ],
          ),
        ),
      ),
    );
  }
}
