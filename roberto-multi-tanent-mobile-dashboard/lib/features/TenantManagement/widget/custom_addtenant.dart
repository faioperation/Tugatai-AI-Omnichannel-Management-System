import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:roberto/app/app_color.dart';
import 'package:roberto/features/TenantManagement/widget/custom_minitextfield.dart';
import 'package:roberto/features/TenantManagement/widget/Custom_MiniDropdown.dart';
import 'package:roberto/features/TenantManagement/bloc/tenant_bloc.dart';
import 'package:roberto/features/TenantManagement/bloc/tenant_event.dart';
import 'package:roberto/features/Subscription/bloc/subscription_bloc.dart';
import 'package:roberto/features/Subscription/bloc/subscription_state.dart';
import 'package:roberto/features/Subscription/bloc/subscription_event.dart';
import 'package:roberto/features/TenantManagement/data/models/tenant_model.dart';

class CustomAddtenant extends StatefulWidget {
  final TenantBusiness? tenant;
  const CustomAddtenant({super.key, this.tenant});

  @override
  State<CustomAddtenant> createState() => _CustomAddtenantState();
}

class _CustomAddtenantState extends State<CustomAddtenant> {
  int selectedTab = 0;
  final _formKey0 = GlobalKey<FormState>();
  final _formKey1 = GlobalKey<FormState>();
  final _formKey2 = GlobalKey<FormState>();
  final _formKey3 = GlobalKey<FormState>();
  
  // Form controllers
  final _businessNameCtrl = TextEditingController();
  final _descriptionCtrl = TextEditingController();
  final _ownerNameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _confirmPasswordCtrl = TextEditingController();
  final _industryCtrl = TextEditingController();

  // Branch controllers
  final _branchNameCtrl = TextEditingController();
  final _branchEmailCtrl = TextEditingController();
  final _branchPhoneCtrl = TextEditingController();
  final _branchAddressCtrl = TextEditingController();

  // Dropdown states
  String selectedBusinessType = "Order Booking";
  String selectedPlanId = "";
  String selectedBillingCycle = "MONTHLY";

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void initState() {
    super.initState();
    // Ensure plans are loaded
    context.read<SubscriptionBloc>().add(FetchSubscriptionsRequested());

    if (widget.tenant != null) {
      final t = widget.tenant!;
      _businessNameCtrl.text = t.name;
      _descriptionCtrl.text = t.description ?? '';
      _ownerNameCtrl.text = t.owner != null ? '${t.owner!.firstName ?? ''} ${t.owner!.lastName ?? ''}'.trim() : '';
      _emailCtrl.text = t.email ?? '';
      _phoneCtrl.text = t.phone ?? '';
      
      if (t.businessType != null && t.businessType!.isNotEmpty) {
        String bt = t.businessType!;
        if (bt == 'ORDER_BOOKING') selectedBusinessType = 'Order Booking';
        else if (bt == 'APPOINTMENT_BOOKING') selectedBusinessType = 'Appointment Booking';
        else if (bt == 'PARCEL_DELIVERY') selectedBusinessType = 'Parcel Delivery';
        else selectedBusinessType = bt;
      }
      _industryCtrl.text = t.industry ?? '';
      
      if (t.planId != null && t.planId!.isNotEmpty) {
        selectedPlanId = t.planId!;
      }
      if (t.planCycle != null && t.planCycle!.isNotEmpty) {
        selectedBillingCycle = t.planCycle!;
      }

      if (t.branches.isNotEmpty) {
        final b = t.branches.first;
        _branchNameCtrl.text = b.name;
        _branchEmailCtrl.text = b.email ?? '';
        _branchPhoneCtrl.text = b.phone ?? '';
        _branchAddressCtrl.text = b.address ?? '';
      }
    }
  }

  @override
  void dispose() {
    _businessNameCtrl.dispose();
    _descriptionCtrl.dispose();
    _ownerNameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _passwordCtrl.dispose();
    _confirmPasswordCtrl.dispose();
    _industryCtrl.dispose();

    _branchNameCtrl.dispose();
    _branchEmailCtrl.dispose();
    _branchPhoneCtrl.dispose();
    _branchAddressCtrl.dispose();
    super.dispose();
  }

  void changeTab(int index) {
    setState(() {
      selectedTab = index;
    });
  }

  void _submit() {
    if (!_formKey2.currentState!.validate()) {
      return;
    }
    
    String apiBusinessType = selectedBusinessType;
    if (selectedBusinessType == 'Order Booking') apiBusinessType = 'ORDER_BOOKING';
    else if (selectedBusinessType == 'Appointment Booking') apiBusinessType = 'APPOINTMENT_BOOKING';
    else if (selectedBusinessType == 'Parcel Delivery') apiBusinessType = 'PARCEL_DELIVERY';

    final payload = <String, dynamic>{
      "businessName": _businessNameCtrl.text,
      "businessType": apiBusinessType,
      "industry": _industryCtrl.text,
      "description": _descriptionCtrl.text,
      "ownerName": _ownerNameCtrl.text,
      "ownerEmail": _emailCtrl.text,
      "ownerPassword": _passwordCtrl.text,
      "ownerPhone": _phoneCtrl.text,
      "planId": selectedPlanId.isNotEmpty ? selectedPlanId : "some-default-plan-id",
      "planCycle": selectedBillingCycle,
    };

    if (_branchNameCtrl.text.isNotEmpty) {
      payload["branch"] = {
        "name": _branchNameCtrl.text,
        "email": _branchEmailCtrl.text,
        "phone": _branchPhoneCtrl.text,
        "address": _branchAddressCtrl.text,
      };
    }

    if (widget.tenant != null) {
      context.read<TenantBloc>().add(UpdateTenantRequested(businessId: widget.tenant!.id, payload: payload));
    } else {
      context.read<TenantBloc>().add(CreateTenantRequested(payload: payload));
    }
    Navigator.pop(context); // Close modal, user can see success message via state if implemented.
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Theme.of(context).cardTheme.color,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Container(
        width: MediaQuery.of(context).size.width < 600
            ? MediaQuery.of(context).size.width * 0.9
            : 500,
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  widget.tenant != null ? "Edit Client" : "Onboard New Client",
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                )
              ],
            ),

            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Set up a new business account with all required information",
                style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color, fontSize: 13),
              ),
            ),

            const SizedBox(height: 20),

            // Tabs
            Container(
              decoration: BoxDecoration(
                color: Theme.of(context).scaffoldBackgroundColor,
                borderRadius: BorderRadius.circular(30),
              ),
              child: Row(
                children: [
                  _tabItem("Business Info", 0),
                  _tabItem("Owner Details", 1),
                  _tabItem("Branch Details", 2),
                  _tabItem("Plan & Settings", 3),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Form content
            IndexedStack(
              index: selectedTab,
              children: [
                _businessInfo(),
                _ownerDetails(),
                _branchDetails(),
                _planSettings(),
              ],
            ),

            const SizedBox(height: 20),

            // Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                OutlinedButton(
                  onPressed: selectedTab > 0 
                      ? () => setState(() => selectedTab--) 
                      : () => Navigator.pop(context),
                  child: Text(
                    selectedTab > 0 ? "Back" : "Cancel",
                    style: const TextStyle(fontSize: 13),
                  ),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: () {
                    bool isValid = false;
                    if (selectedTab == 0) {
                      isValid = _formKey0.currentState!.validate();
                    } else if (selectedTab == 1) {
                      isValid = _formKey1.currentState!.validate();
                    } else if (selectedTab == 2) {
                      isValid = _formKey3.currentState!.validate();
                    } else if (selectedTab == 3) {
                      isValid = _formKey2.currentState!.validate();
                    }
                    
                    if (!isValid) return;

                    if (selectedTab < 3) {
                      setState(() => selectedTab++);
                    } else {
                      _submit();
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColor.primary,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    selectedTab < 3 
                        ? 'Next' 
                        : (widget.tenant != null ? 'Update Client' : 'Create Client'),
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _tabItem(String text, int index) {
    final active = selectedTab == index;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          // Validate the current tab before switching
          bool isValid = true;
          if (selectedTab == 0) {
             isValid = _formKey0.currentState!.validate();
          } else if (selectedTab == 1) {
             isValid = _formKey1.currentState!.validate();
          } else if (selectedTab == 2) {
             isValid = _formKey3.currentState!.validate();
          } else if (selectedTab == 3) {
             isValid = _formKey2.currentState!.validate();
          }
          if (!isValid) return;

          changeTab(index);
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: active ? Theme.of(context).primaryColor.withValues(alpha: 0.1) : Colors.transparent,
            borderRadius: BorderRadius.circular(30),
          ),
          child: Center(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 12,
                color: active ? Theme.of(context).primaryColor : Theme.of(context).textTheme.bodyMedium?.color,
                fontWeight: active ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _businessInfo() {
    return Form(
      key: _formKey0,
      child: Column(
        children: [
        _inputLabel("Business Name"),
        const SizedBox(height: 5),
        CustomMinitextfield(
          hint: "Enter business name", 
          controller: _businessNameCtrl,
          validator: (val) => val == null || val.isEmpty ? "Business name is required" : null,
        ),

        const SizedBox(height: 12),

        _inputLabel("Business Type"),
        const SizedBox(height: 5),
        CustomMiniDropdown(
          value: selectedBusinessType,
          items: const ["Order Booking", "Appointment Booking", "Parcel Delivery"],
          hint: "Select type",
          tooltips: const {
            "Order Booking": "Manage customer orders, food delivery, or product sales.",
            "Appointment Booking": "Schedule and manage appointments for salons, clinics, or consulting.",
            "Parcel Delivery": "Manage logistics, parcel delivery, or cargo tracking.",
          },
          onChanged: (val) => setState(() => selectedBusinessType = val ?? "Order Booking"),
        ),

        const SizedBox(height: 12),

        _inputLabel("Industry (optional)"),
        const SizedBox(height: 5),
        CustomMinitextfield(
          hint: "Enter industry", 
          controller: _industryCtrl,
        ),

        const SizedBox(height: 12),

        _inputLabel("Description"),
        const SizedBox(height: 5),
        CustomMinitextfield(
          hint: "Brief description of the business...",
          maxLines: 3,
          controller: _descriptionCtrl,
        ),
      ],
    ),
    );
  }

  Widget _ownerDetails() {
    return Form(
      key: _formKey1,
      child: Column(
        children: [
        _inputLabel("Owner Name"),
        const SizedBox(height: 5),
        CustomMinitextfield(
          hint: "Enter owner name", 
          controller: _ownerNameCtrl,
          validator: (val) => val == null || val.isEmpty ? "Owner name is required" : null,
        ),

        const SizedBox(height: 12),

        _inputLabel("Email"),
        const SizedBox(height: 5),
        CustomMinitextfield(
          hint: "Enter email", 
          controller: _emailCtrl,
          keyboardType: TextInputType.emailAddress,
          validator: (val) {
            if (val == null || val.isEmpty) return "Email is required";
            if (!val.contains('@')) return "Enter a valid email";
            return null;
          },
        ),

        const SizedBox(height: 12),

        _inputLabel("Phone"),
        const SizedBox(height: 5),
        CustomMinitextfield(
          hint: "Enter phone (+880...)", 
          controller: _phoneCtrl,
          keyboardType: TextInputType.phone,
          validator: (val) => val == null || val.isEmpty ? "Phone is required" : null,
        ),

        const SizedBox(height: 12),

        _inputLabel(widget.tenant != null ? "New Password (optional)" : "Initial Password"),
        const SizedBox(height: 5),
        CustomMinitextfield(
          hint: widget.tenant != null ? "Enter new password" : "Create password", 
          controller: _passwordCtrl, 
          obscureText: _obscurePassword,
          suffixIcon: IconButton(
            icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility, color: Colors.grey),
            onPressed: () {
              setState(() {
                _obscurePassword = !_obscurePassword;
              });
            },
          ),
          validator: (val) {
            if (widget.tenant == null && (val == null || val.isEmpty)) {
              return "Password is required";
            }
            if (val != null && val.isNotEmpty && val.length < 6) {
              return "Password must be at least 6 characters";
            }
            return null;
          },
        ),

        const SizedBox(height: 12),

        _inputLabel(widget.tenant != null ? "Confirm New Password" : "Confirm Password"),
        const SizedBox(height: 5),
        CustomMinitextfield(
          hint: widget.tenant != null ? "Confirm new password" : "Confirm password", 
          controller: _confirmPasswordCtrl, 
          obscureText: _obscureConfirmPassword,
          suffixIcon: IconButton(
            icon: Icon(_obscureConfirmPassword ? Icons.visibility_off : Icons.visibility, color: Colors.grey),
            onPressed: () {
              setState(() {
                _obscureConfirmPassword = !_obscureConfirmPassword;
              });
            },
          ),
          validator: (val) {
            if (widget.tenant == null && (val == null || val.isEmpty)) {
              return "Confirm password is required";
            }
            if (val != _passwordCtrl.text) {
              return "Passwords do not match";
            }
            return null;
          },
        ),
      ],
    ),
    );
  }

  Widget _branchDetails() {
    return Form(
      key: _formKey3,
      child: Column(
        children: [
        _inputLabel("Branch Name"),
        const SizedBox(height: 5),
        CustomMinitextfield(
          hint: "Enter branch name", 
          controller: _branchNameCtrl,
          validator: (val) => val == null || val.isEmpty ? "Branch name is required" : null,
        ),

        const SizedBox(height: 12),

        _inputLabel("Email"),
        const SizedBox(height: 5),
        CustomMinitextfield(
          hint: "Enter branch email", 
          controller: _branchEmailCtrl,
          keyboardType: TextInputType.emailAddress,
          validator: (val) {
            if (val == null || val.isEmpty) return "Email is required";
            if (!val.contains('@')) return "Enter a valid email";
            return null;
          },
        ),

        const SizedBox(height: 12),

        _inputLabel("Phone"),
        const SizedBox(height: 5),
        CustomMinitextfield(
          hint: "Enter branch phone", 
          controller: _branchPhoneCtrl,
          keyboardType: TextInputType.phone,
          validator: (val) => val == null || val.isEmpty ? "Phone is required" : null,
        ),

        const SizedBox(height: 12),

        _inputLabel("Address"),
        const SizedBox(height: 5),
        CustomMinitextfield(
          hint: "Enter branch address", 
          controller: _branchAddressCtrl,
          validator: (val) => val == null || val.isEmpty ? "Address is required" : null,
        ),
      ],
    ),
    );
  }

  Widget _planSettings() {
    return BlocBuilder<SubscriptionBloc, SubscriptionState>(
      builder: (context, state) {
        if (state is SubscriptionLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        List<String> planOptions = ["No Plans Found"];
        Map<String, String> planMap = {}; // name -> id

        if (state is SubscriptionLoaded) {
          final plans = state.subscriptionData.plans;
          if (plans.isNotEmpty) {
            planOptions = [];
            for (var plan in plans) {
              planOptions.add(plan.name);
              planMap[plan.name] = plan.id;
            }
            if (selectedPlanId.isEmpty || !planMap.values.contains(selectedPlanId)) {
              selectedPlanId = plans.first.id;
            }
          }
        }

        String currentPlanName = planMap.entries
            .firstWhere((e) => e.value == selectedPlanId, orElse: () => const MapEntry("Select plan", ""))
            .key;
            
        if (!planOptions.contains(currentPlanName)) {
           if(planOptions.isNotEmpty){
             currentPlanName = planOptions.first;
           }
        }

        return Form(
          key: _formKey2,
          child: Column(
            children: [
            _inputLabel("Subscription Plan"),
            const SizedBox(height: 5),
            CustomMiniDropdown(
              value: currentPlanName,
              items: planOptions,
              hint: "Select plan",
              onChanged: (val) {
                if (val != null && planMap.containsKey(val)) {
                  setState(() => selectedPlanId = planMap[val]!);
                }
              },
            ),

            const SizedBox(height: 12),

            _inputLabel("Billing Cycle"),
            const SizedBox(height: 5),
            CustomMiniDropdown(
              value: selectedBillingCycle,
              items: const ["MONTHLY", "YEARLY"],
              hint: "Select cycle",
              onChanged: (val) => setState(() => selectedBillingCycle = val ?? "MONTHLY"),
            ),
          ],
        ),
        );
      },
    );
  }

  Widget _inputLabel(String text) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        text,
        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
      ),
    );
  }
}