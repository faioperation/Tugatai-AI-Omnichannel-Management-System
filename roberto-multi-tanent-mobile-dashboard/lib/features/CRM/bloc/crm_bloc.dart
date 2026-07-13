import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:roberto/features/CRM/data/repositories/crm_repository.dart';
import 'package:roberto/common/user_role.dart';
import 'crm_event.dart';
import 'crm_state.dart';

class CrmBloc extends Bloc<CrmEvent, CrmState> {
  final CrmRepository crmRepository;

  CrmBloc({required this.crmRepository}) : super(CrmInitial()) {
    on<FetchLeads>(_onFetchLeads);
    on<CreateLead>(_onCreateLead);
    on<UpdateLead>(_onUpdateLead);
    on<DeleteLead>(_onDeleteLead);
  }

  Future<void> _onFetchLeads(FetchLeads event, Emitter<CrmState> emit) async {
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
        // Automatically fetch leads again after a successful creation
        add(FetchLeads(branchId: event.branchId, role: event.role));
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
        // Automatically fetch leads again after a successful update
        if (event.branchId != null) {
          add(FetchLeads(branchId: event.branchId!, role: event.role));
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
        // Automatically fetch leads again after a successful deletion
        add(FetchLeads(branchId: event.branchId, role: event.role));
      } else {
        emit(CrmError(message: response['message'] ?? 'Failed to delete lead'));
      }
    } catch (e) {
      emit(CrmError(message: e.toString()));
    }
  }
}
