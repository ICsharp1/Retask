import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/step.dart';
import '../../providers/theme_provider.dart';
import 'step_actions_menu.dart';
import 'step_radio_button.dart';

class StepItem extends StatefulWidget {
  final TaskStep step;
  final List<TaskStep>? parentList;
  final double indentation;
  final Function(TaskStep) onStepSelected;
  final Function(TaskStep) onStepDeleted;
  final Function(TaskStep) onStepEdited;
  final Function(TaskStep) onTextAdded;
  final Function(TaskStep) onStepAdded;

  const StepItem({
    super.key,
    required this.step,
    this.parentList,
    required this.indentation,
    required this.onStepSelected,
    required this.onStepDeleted,
    required this.onStepEdited,
    required this.onTextAdded,
    required this.onStepAdded,
  });

  @override
  State<StepItem> createState() => _StepItemState();
}

class _StepItemState extends State<StepItem> {
  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final settings = themeProvider.settings;

    return Padding(
      padding: EdgeInsets.only(left: widget.indentation.toDouble()),
      child: widget.step.isTextOnly 
        ? GestureDetector(
            onDoubleTap: () => widget.onStepEdited(widget.step),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Text(
                widget.step.title,
                style: TextStyle(color: settings.notesTextColor),
              ),
            ),
          )
        : Container(
            margin: const EdgeInsets.symmetric(vertical: 4.0),
            decoration: BoxDecoration(
              border: Border.all(
                color: settings.notesCardBorderColor.withOpacity(0.3),
                width: 1.0,
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Theme(
              data: Theme.of(context).copyWith(
                dividerColor: Colors.transparent,
              ),
              child: ExpansionTile(
                leading: StepRadioButton(
                  isSelected: widget.step.isCurrent,
                  onSelect: () {
                    widget.onStepSelected(widget.step);
                    if (widget.step.subSteps.isNotEmpty) {
                      setState(() {
                        widget.step.isExpanded = true;
                      });
                    }
                  },
                  activeColor: settings.notesTextColor,
                ),
                title: Text(
                  widget.step.title,
                  style: TextStyle(color: settings.notesTextColor),
                ),
                initiallyExpanded: widget.step.isExpanded,
                onExpansionChanged: (expanded) {
                  setState(() {
                    widget.step.isExpanded = expanded;
                    // If collapsing and has a current substep, store it and make this step current
                    if (!expanded) {
                      final currentSubstep = _findCurrentSubstep(widget.step);
                      if (currentSubstep != null) {
                        widget.step.lastCurrentSubstep = currentSubstep;
                        widget.onStepSelected(widget.step);
                      }
                    } else if (widget.step.lastCurrentSubstep != null) {
                      // If expanding and has a stored current substep, restore it
                      widget.onStepSelected(widget.step.lastCurrentSubstep!);
                      widget.step.lastCurrentSubstep = null;
                    }
                  });
                },
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    StepActionsMenu(
                      onAddText: () => widget.onTextAdded(widget.step),
                      onAddStep: () => widget.onStepAdded(widget.step),
                      onEdit: () => widget.onStepEdited(widget.step),
                      onDelete: () => widget.onStepDeleted(widget.step),
                      iconColor: settings.notesTextColor,
                    ),
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 200),
                      child: Icon(
                        widget.step.isExpanded ? Icons.expand_less : Icons.expand_more,
                        key: ValueKey<bool>(widget.step.isExpanded),
                        color: settings.notesTextColor,
                      ),
                    ),
                  ],
                ),
                children: [
                  if (widget.step.description.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16.0),
                        decoration: BoxDecoration(
                          color: settings.notesBackgroundColor,
                          border: Border.all(color: settings.notesCardBorderColor),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          widget.step.description,
                          style: TextStyle(color: settings.notesTextColor),
                        ),
                      ),
                    ),
                  ...widget.step.subSteps.map((subStep) {
                    return StepItem(
                      step: subStep,
                      parentList: widget.step.subSteps,
                      indentation: widget.indentation + 32,
                      onStepSelected: (step) {
                        widget.onStepSelected(step);
                        if (step.subSteps.isNotEmpty) {
                          setState(() {
                            step.isExpanded = true;
                          });
                        }
                      },
                      onStepDeleted: widget.onStepDeleted,
                      onStepEdited: widget.onStepEdited,
                      onTextAdded: widget.onTextAdded,
                      onStepAdded: widget.onStepAdded,
                    );
                  }).toList(),
                ],
              ),
            ),
          ),
    );
  }

  TaskStep? _findCurrentSubstep(TaskStep step) {
    for (var substep in step.subSteps) {
      if (substep.isCurrent) return substep;
      final current = _findCurrentSubstep(substep);
      if (current != null) return current;
    }
    return null;
  }
}
