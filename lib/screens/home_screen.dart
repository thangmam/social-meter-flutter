import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:social_meter/models/activity.dart';
import 'package:social_meter/widgets/dialogs/add_activity_dialog.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _activityList = <Activity>[];
  double _currentEnergy = 1; // 1 = 100%
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              TweenAnimationBuilder(
                tween: Tween<double>(begin: 1, end: _currentEnergy),
                duration: Duration(seconds: 1),
                builder: (context, value, _) {
                  return LinearProgressIndicator(
                    value: value,
                    minHeight: 15,
                    backgroundColor: Colors.grey.shade400,
                    borderRadius: BorderRadius.circular(30),
                  );
                },
              ),
              SizedBox(height: 10),
              Expanded(
                child: ListView.builder(
                  itemBuilder: (context, index) {
                    if (index == _activityList.length) {
                      return TextButton(
                        onPressed: () async {
                          final result = await showDialog<String?>(
                            context: context,
                            builder: (context) => AddActivityDialog(),
                          );
                          log("result $result", name: 'home_screen');
                          if (result != null) {
                            _activityList.add(
                              Activity(
                                energy: 0.0,
                                isEnabled: true,
                                name: result,
                              ),
                            );
                            setState(() {});
                          }
                        },
                        child: Text("Add more"),
                      );
                    }
                    return _buildCard(index);
                  },
                  itemCount: _activityList.length + 1,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCard(int index) {
    final item = _activityList[index];
    return Card.outlined(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Row(
              children: [
                Text(
                  item.name,
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                Spacer(),
                Checkbox(
                  value: item.isEnabled,
                  onChanged: (s) {
                    _updateCheckboxState(s, item, index);
                  },
                ),
                IconButton(
                  onPressed: () {
                    _activityList.removeAt(index);
                    _updateEnergy();
                    setState(() {});
                  },
                  icon: Icon(Icons.delete),
                ),
              ],
            ),
            Slider(
              value: item.energy * 100,
              min: 0,
              max: 100,
              label: "${(item.energy * 100).toStringAsFixed(2)}%",
              divisions: 100,
              onChanged: (s) {
                _updateSliderValue(item, index, (s / 100));
              },
            ),
          ],
        ),
      ),
    );
  }

  void _updateSliderValue(Activity item, int index, double s) {
    final newActivity = item.copyWith(energy: s);

    log("slider value $s  | $_currentEnergy");

    // final newActivity = Activity(energy: s,name: item.name,isEnabled: item.isEnabled);
    _activityList[index] = newActivity;
    _updateEnergy();
    setState(() {});
  }

  void _updateEnergy() {
    final totalActivityEnergy = _activityList.fold<double>(0.0, (
      previousValue,
      element,
    ) {
      if (!element.isEnabled) {
        return previousValue;
      }
      return previousValue + element.energy;
    });

    _currentEnergy = 1 - totalActivityEnergy;
  }

  void _updateCheckboxState(bool? isChecked, Activity item, int index) {
    if (isChecked != null) {
      final newActivity = item.copyWith(isEnabled: isChecked);
      _activityList[index] = newActivity;
      _updateEnergy();
      setState(() {});
    }
  }
}
