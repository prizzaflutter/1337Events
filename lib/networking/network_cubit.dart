import 'dart:async';
import 'package:equatable/equatable.dart';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;

import 'package:bloc/bloc.dart';
import 'package:connectivity_plus/connectivity_plus.dart';


part 'network_state.dart';

class NetworkCubit extends Cubit<NetworkState> {
  late final StreamSubscription<List<ConnectivityResult>>
      _connectivityStreamSubscription;

  NetworkCubit() : super(NetworkInitial()) {
    _initializeConnectivity();
    _connectivityStreamSubscription = Connectivity().onConnectivityChanged.listen(_connectivityChanged);
  }

  Future<void> _initializeConnectivity() async {
    try {
      final result = await Connectivity().checkConnectivity();
     await  _connectivityChanged(result);
    } catch (e) {
      emit(NetworkDisconnected());
    }
  }

  Future<void> _connectivityChanged(List<ConnectivityResult> result) async {
    if (result.contains(ConnectivityResult.mobile) ||
        result.contains(ConnectivityResult.wifi)) {
      bool isConnected = await _checkInternetAccess();
      if (isConnected) {
        debugPrint('Connected ================> network_cubit');
        emit(NetworkConnected());
      } else {
        debugPrint('Disconnected ================> network_cubit');
        emit(NetworkDisconnected());
      }
    } else {
      emit(NetworkDisconnected());
    }
  }

  Future<bool> _checkInternetAccess() async {
    try {
      final response = await http
          .get(Uri.parse('https://www.google.com'))
          .timeout(const Duration(seconds: 5));
      if (response.statusCode == 200) {
        debugPrint("Connected to the internet ========================================> network_cubit");
        return true;
      } else {
        debugPrint("Disconnected from the internet ========================================> network_cubit over here");
        return false;
      }
    } catch (e) {
      return false;
    }
  }

  Future<void> checkConnectivity() async {
    var result = await Connectivity().checkConnectivity();
    await _connectivityChanged(result);
  }

  @override
  Future<void> close() {
    _connectivityStreamSubscription.cancel();
    return super.close();
  }
}
