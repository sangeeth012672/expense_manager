import 'package:bloc/bloc.dart';
import '../repositories/sync_repository.dart';
import 'sync_event.dart';
import 'sync_state.dart';

class SyncBloc extends Bloc<SyncEvent, SyncState> {
  final SyncRepository syncRepository;

  SyncBloc({required this.syncRepository}) : super(SyncInitial()) {
    on<StartSync>(_onStartSync);
  }

  Future<void> _onStartSync(StartSync event, Emitter<SyncState> emit) async {
    emit(SyncInProgress());
    try {
      await syncRepository.performSync();
      emit(SyncSuccess());
    } catch (e) {
      emit(SyncFailure(e.toString()));
    }
  }
}
