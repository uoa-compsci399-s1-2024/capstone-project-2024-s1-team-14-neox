part of 'bluetooth_bloc.dart';

sealed class BluetoothState extends Equatable {
  const BluetoothState();
  
  @override
  List<Object> get props => [];
}

final class BluetoothInitial extends BluetoothState {}
