import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:roberto/features/CRM/data/repositories/crm_repository.dart';
import 'package:roberto/common/user_role.dart';
import 'crm_event.dart';
import 'crm_state.dart';

class CrmBloc extends Bloc<CrmEvent, CrmState> {
  final CrmRepository crmRepository;

  // Track last used fetch params so refresh after CRUD preserves page/filters
  FetchLeads? _lastFetchLeads;

  CrmBloc({required this.crmRepository}) : super(CrmInitial()) {
    on<FetchLeads>(_onFetchLeads);
    on<CreateLead>(_onCreateLead);
    on<UpdateLead>(_onUpdateLead);
    on<DeleteLead>(_onDeleteLead);
  }

  Future<void> _onFetchLeads(FetchLeads event, Emitter<CrmState> emit) async {
    _lastFetchLeads = event; // Remember the last filter state
    emit(CrmLoading());
    try {
      final response = await crmRepository.getLeads(
        branchId: event.branchId,
        page: event.page,
        limit: event.limit,
        searchParam: event.searchParam,
        isBranchManager: event.role == UserRole.branchManager,
        country: event.country,
        productType: event.productType,
      );

      if (response['success'] == true) {
        emit(CrmLeadsLoaded(
          leads: response['leads'],
          meta: response['meta'],
        ));
      } else {
        emit(CrmError(message: response['message'] ?? 'Failed to fetch leads'));
      }
    } catch (e) {
      emit(CrmError(message: e.toString()));
    }
  }

  /// Refresh using last-known filter params so list stays consistent after CRUD
  void _refreshWithFilters(String branchId, UserRole role) {
    final last = _lastFetchLeads;
    add(FetchLeads(
      branchId: branchId,
      role: role,
      page: last?.page ?? 1,
      limit: last?.limit ?? 10,
      searchParam: last?.searchParam ?? '',
      country: last?.country ?? '',
      productType: last?.productType ?? '',
    ));
  }

  Future<void> _onCreateLead(CreateLead event, Emitter<CrmState> emit) async {
    emit(CrmActionLoading());
    try {
      final response = await crmRepository.createLead(
        branchId: event.branchId,
        name: event.name,
        email: event.email,
        phone: event.phone,
        source: event.source,
        country: event.country,
        address: event.address,
        note: event.note,
        status: event.status,
        metadata: event.metadata,
        isBranchManager: event.role == UserRole.branchManager,
      );

      if (response['success'] == true) {
        emit(CrmActionSuccess(message: response['message'] ?? 'Lead created successfully'));
        // Refresh preserving current page and filters
        _refreshWithFilters(event.branchId, event.role);
      } else {
        emit(CrmError(message: response['message'] ?? 'Failed to create lead'));
      }
    } catch (e) {
      emit(CrmError(message: e.toString()));
    }
  }

  Future<void> _onUpdateLead(UpdateLead event, Emitter<CrmState> emit) async {
    emit(CrmActionLoading());
    try {
      final response = await crmRepository.updateLead(
        id: event.id,
        branchId: event.branchId,
        name: event.name,
        email: event.email,
        phone: event.phone,
        source: event.source,
        address: event.address,
        note: event.note,
        status: event.status,
        metadata: event.metadata,
        isBranchManager: event.role == UserRole.branchManager,
      );

      if (response['success'] == true) {
        emit(CrmActionSuccess(message: response['message'] ?? 'Lead updated successfully'));
        // Refresh preserving current page and filters
        if (event.branchId != null) {
          _refreshWithFilters(event.branchId!, event.role);
        }
      } else {
        emit(CrmError(message: response['message'] ?? 'Failed to update lead'));
      }
    } catch (e) {
      emit(CrmError(message: e.toString()));
    }
  }

  Future<void> _onDeleteLead(DeleteLead event, Emitter<CrmState> emit) async {
    emit(CrmActionLoading());
    try {
      final response = await crmRepository.deleteLead(
        id: event.id,
        isBranchManager: event.role == UserRole.branchManager,
      );

      if (response['success'] == true) {
        emit(CrmActionSuccess(message: response['message'] ?? 'Lead deleted successfully'));
        // Refresh preserving current page and filters
        _refreshWithFilters(event.branchId, event.role);
      } else {
        emit(CrmError(message: response['message'] ?? 'Failed to delete lead'));
      }
    } catch (e) {
      emit(CrmError(message: e.toString()));
    }
  }
}
