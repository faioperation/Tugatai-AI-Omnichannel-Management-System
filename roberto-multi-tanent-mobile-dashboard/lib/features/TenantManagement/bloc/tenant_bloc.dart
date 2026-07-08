import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:roberto/features/TenantManagement/data/repositories/tenant_repository.dart';
import 'tenant_event.dart';
import 'tenant_state.dart';

class TenantBloc extends Bloc<TenantEvent, TenantState> {
  final TenantRepository tenantRepository;
  String? currentSearchParam;

  TenantBloc({required this.tenantRepository}) : super(TenantInitial()) {
    on<FetchTenantsRequested>(_onFetchTenantsRequested);
    on<CreateTenantRequested>(_onCreateTenantRequested);
    on<UpdateTenantRequested>(_onUpdateTenantRequested);
    on<DeleteTenantRequested>(_onDeleteTenantRequested);
  }

  Future<void> _onFetchTenantsRequested(
    FetchTenantsRequested event,
    Emitter<TenantState> emit,
  ) async {
    emit(TenantLoading());
    try {
      currentSearchParam = event.searchParam;
      final response = await tenantRepository.getAllTenants(searchParam: currentSearchParam);
      emit(TenantLoaded(tenantResponse: response));
    } catch (e) {
      emit(TenantError(message: e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> _onCreateTenantRequested(
    CreateTenantRequested event,
    Emitter<TenantState> emit,
  ) async {
    emit(TenantActionLoading());
    try {
      await tenantRepository.createTenant(event.payload);
      emit(const TenantActionSuccess(message: 'Business created successfully'));
      add(FetchTenantsRequested(searchParam: currentSearchParam)); // Refresh list
    } catch (e) {
      emit(TenantError(message: e.toString().replaceAll('Exception: ', '')));
      add(FetchTenantsRequested(searchParam: currentSearchParam)); // Refresh list
    }
  }

  Future<void> _onUpdateTenantRequested(
    UpdateTenantRequested event,
    Emitter<TenantState> emit,
  ) async {
    emit(TenantActionLoading());
    try {
      await tenantRepository.updateTenant(event.businessId, event.payload);
      emit(const TenantActionSuccess(message: 'Business updated successfully'));
      add(FetchTenantsRequested(searchParam: currentSearchParam)); // Refresh list
    } catch (e) {
      emit(TenantError(message: e.toString().replaceAll('Exception: ', '')));
      add(FetchTenantsRequested(searchParam: currentSearchParam)); // Refresh list
    }
  }

  Future<void> _onDeleteTenantRequested(
    DeleteTenantRequested event,
    Emitter<TenantState> emit,
  ) async {
    emit(TenantActionLoading());
    try {
      await tenantRepository.deleteTenant(event.businessId);
      emit(const TenantActionSuccess(message: 'Business deleted successfully'));
      add(FetchTenantsRequested(searchParam: currentSearchParam)); // Refresh list
    } catch (e) {
      emit(TenantError(message: e.toString().replaceAll('Exception: ', '')));
      add(FetchTenantsRequested(searchParam: currentSearchParam)); // Refresh list
    }
  }
}
