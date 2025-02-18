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
  final Function(TaskStep) onStepAdded;
  final void Function(TaskStep, TaskStep?, bool)? onStepReordered;

  const StepItem({
    super.key,
    required this.step,
    this.parentList,
    required this.indentation,
    required this.onStepSelected,
    required this.onStepDeleted,
    required this.onStepEdited,
    required this.onStepAdded,
    this.onStepReordered,
  });

  @override
  State<StepItem> createState() => _StepItemState();
}

class _StepItemState extends State<StepItem> {
  bool isDragging = false;

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final settings = themeProvider.settings;

    return Column(
      children: [
        Draggable<TaskStep>(
          data: widget.step,
          onDragStarted: () => setState(() => isDragging = true),
          onDragEnd: (_) => setState(() => isDragging = false),
          feedback: Material(
            elevation: 6,
            child: Container(
              width: MediaQuery.of(context).size.width - widget.indentation,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: settings.currentStepColor.withOpacity(0.9),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                widget.step.title,
                style: TextStyle(
                  fontSize: 16,
                  color: settings.textColor,
                ),
              ),
            ),
          ),
          child: DragTarget<TaskStep>(
            onWillAccept: (data) {
              if (data == null) return false;
              return data != widget.step &&
                  !(widget.step.subSteps.contains(data)) &&
                  data !=
                      widget.parentList?.firstWhere(
                          (step) => step.subSteps.contains(widget.step),
                          orElse: () => widget.step);
            },
            onAccept: (data) {
              if (widget.onStepReordered != null) {
                widget.onStepReordered!(data, widget.step, false);
              }
            },
            builder: (context, candidateData, rejectedData) {
              return Opacity(
                opacity: isDragging ? 0.5 : 1.0,
                child: Container(
                  padding: EdgeInsets.only(left: widget.indentation),
                  margin: const EdgeInsets.symmetric(vertical: 2.0),
                  decoration: BoxDecoration(
                    color: widget.step.isCurrent
                        ? settings.currentStepColor
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(8),
                    border: candidateData.isNotEmpty
                        ? Border.all(
                            color: settings.currentStepColor,
                            width: 2,
                          )
                        : null,
                  ),
                  child: Row(
                    children: [
                      if (widget.step.subSteps.isNotEmpty)
                        IconButton(
                          icon: AnimatedRotation(
                            duration: const Duration(milliseconds: 200),
                            turns: widget.step.isExpanded ? 0.25 : 0,
                            child: Icon(
                              Icons.chevron_right,
                              color: settings.textColor,
                            ),
                          ),
                          onPressed: () {
                            setState(() {
                              widget.step.isExpanded = !widget.step.isExpanded;
                            });
                          },
                        ),
                      StepRadioButton(
                        isSelected: widget.step.isCurrent,
                        onSelect: () => widget.onStepSelected(widget.step),
                      ),
                      Expanded(
                        child: GestureDetector(
                          onDoubleTap: () => widget.onStepEdited(widget.step),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                            child: Text(
                              widget.step.title,
                              style: TextStyle(
                                fontSize: 16,
                                color: settings.textColor,
                                fontWeight: widget.step.subSteps.isNotEmpty
                                    ? FontWeight.w500
                                    : FontWeight.normal,
                              ),
                            ),
                          ),
                        ),
                      ),
                      StepActionsMenu(
                        step: widget.step,
                        parentList: widget.parentList,
                        onStepDeleted: widget.onStepDeleted,
                        onStepEdited: widget.onStepEdited,
                        onStepAdded: widget.onStepAdded,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        if (widget.step.isExpanded && widget.step.subSteps.isNotEmpty)
          ...widget.step.subSteps
              .map(
                (subStep) => StepItem(
                  key: ValueKey('${widget.step.title}-${subStep.title}'),
                  step: subStep,
                  parentList: widget.step.subSteps,
                  indentation: widget.indentation + 32,
                  onStepSelected: widget.onStepSelected,
                  onStepDeleted: widget.onStepDeleted,
                  onStepEdited: widget.onStepEdited,
                  onStepAdded: widget.onStepAdded,
                  onStepReordered: widget.onStepReordered,
                ),
              )
              .toList(),
      ],
    );
  }
}
