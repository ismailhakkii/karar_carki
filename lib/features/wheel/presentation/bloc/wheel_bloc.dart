import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:karar_carki/features/wheel/domain/entities/wheel.dart';
import 'package:karar_carki/features/wheel/domain/usecases/get_all_wheels.dart';
import 'package:karar_carki/features/wheel/domain/usecases/save_wheel.dart';

// Events
abstract class WheelEvent extends Equatable {
  const WheelEvent();

  @override
  List<Object?> get props => [];
}

class LoadWheels extends WheelEvent {
  const LoadWheels();
}

class AddWheel extends WheelEvent {
  final Wheel wheel;

  const AddWheel(this.wheel);

  @override
  List<Object?> get props => [wheel];
}

class UpdateWheel extends WheelEvent {
  final Wheel wheel;

  const UpdateWheel(this.wheel);

  @override
  List<Object?> get props => [wheel];
}

class DeleteWheel extends WheelEvent {
  final Wheel wheel;

  const DeleteWheel(this.wheel);

  @override
  List<Object?> get props => [wheel];
}

// States
abstract class WheelState extends Equatable {
  const WheelState();

  @override
  List<Object?> get props => [];
}

class WheelInitial extends WheelState {}

class WheelLoading extends WheelState {}

class WheelLoaded extends WheelState {
  final List<Wheel> wheels;

  const WheelLoaded({required this.wheels});

  @override
  List<Object?> get props => [wheels];
}

class WheelError extends WheelState {
  final String message;

  const WheelError({required this.message});

  @override
  List<Object?> get props => [message];
}

// BLoC
class WheelBloc extends Bloc<WheelEvent, WheelState> {
  final GetAllWheels getAllWheels;
  final SaveWheel saveWheel;

  WheelBloc({
    required this.getAllWheels,
    required this.saveWheel,
  }) : super(WheelInitial()) {
    on<LoadWheels>(_onLoadWheels);
    on<AddWheel>(_onAddWheel);
    on<UpdateWheel>(_onUpdateWheel);
    on<DeleteWheel>(_onDeleteWheel);
  }

  Future<void> _onLoadWheels(LoadWheels event, Emitter<WheelState> emit) async {
    emit(WheelLoading());
    try {
      final wheels = await getAllWheels();
      emit(WheelLoaded(wheels: wheels));
    } catch (e) {
      emit(WheelError(message: e.toString()));
    }
  }

  Future<void> _onAddWheel(AddWheel event, Emitter<WheelState> emit) async {
    try {
      await saveWheel(event.wheel);
      final wheels = await getAllWheels();
      emit(WheelLoaded(wheels: wheels));
    } catch (e) {
      emit(WheelError(message: e.toString()));
    }
  }

  Future<void> _onUpdateWheel(UpdateWheel event, Emitter<WheelState> emit) async {
    try {
      await saveWheel(event.wheel);
      final wheels = await getAllWheels();
      emit(WheelLoaded(wheels: wheels));
    } catch (e) {
      emit(WheelError(message: e.toString()));
    }
  }

  Future<void> _onDeleteWheel(DeleteWheel event, Emitter<WheelState> emit) async {
    try {
      await saveWheel(event.wheel);
      final wheels = await getAllWheels();
      emit(WheelLoaded(wheels: wheels));
    } catch (e) {
      emit(WheelError(message: e.toString()));
    }
  }
} 