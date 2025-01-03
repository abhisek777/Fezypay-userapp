import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:six_cash/common/widgets/custom_dialog_widget.dart';
import 'package:six_cash/common/widgets/custom_pop_scope_widget.dart';
import 'package:six_cash/features/setting/controllers/edit_profile_controller.dart';
import 'package:six_cash/features/setting/controllers/profile_screen_controller.dart';
import 'package:six_cash/features/camera_verification/controllers/camera_screen_controller.dart';
import 'package:six_cash/common/models/signup_body_model.dart';
import 'package:six_cash/helper/dialog_helper.dart';
import 'package:six_cash/helper/route_helper.dart';
import 'package:six_cash/util/dimensions.dart';
import 'package:six_cash/common/widgets/custom_app_bar_widget.dart';
import 'package:six_cash/common/widgets/custom_large_widget.dart';
import 'package:six_cash/features/auth/widgets/gender_field_widget.dart';
import 'package:six_cash/features/auth/widgets/sign_up_input_widget.dart';

class SignUpInformationScreen extends StatefulWidget {
  const SignUpInformationScreen({super.key});

  @override
  State<SignUpInformationScreen> createState() => _SignUpInformationScreenState();
}

class _SignUpInformationScreenState extends State<SignUpInformationScreen> {
  TextEditingController occupationTextController = TextEditingController();
  TextEditingController fNameTextController = TextEditingController();
  TextEditingController lNameTextController = TextEditingController();
  TextEditingController emailTextController = TextEditingController();

  final GlobalKey<FormState> formKey = GlobalKey<FormState>();


  @override
  void dispose() {
    super.dispose();
    occupationTextController.dispose();
    fNameTextController.dispose();
    lNameTextController.dispose();
    emailTextController.dispose();
  }

  @override
  void initState() {
    Get.find<EditProfileController>().setGender('Male') ;


    super.initState();
  }


  @override
  Widget build(BuildContext context) {
    return CustomPopScopeWidget(
      isExit: false,
      onPopInvoked:()=> _onWillPop(context),
      child: Scaffold(
        appBar: CustomAppbarWidget(title: 'information'.tr, onTap: ()=> _onWillPop(context)),

        body: Column(children: [
          Expanded(flex: 10, child: SingleChildScrollView(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

            const GenderFieldWidget(),
            const SizedBox(height: Dimensions.paddingSizeLarge),

            Form(
              key: formKey,
              child: SignUpInputWidget(
                occupationController: occupationTextController,
                fNameController: fNameTextController,
                lNameController: lNameTextController,
                emailController: emailTextController,
              ),
            ),
            const SizedBox(height: Dimensions.paddingSizeExtraOverLarge),

          ]))),

          SafeArea(child: GetBuilder<ProfileController>(builder: (getController) {
            return CustomLargeButtonWidget(
              backgroundColor: Theme.of(context).secondaryHeaderColor,
              fontSize: Dimensions.fontSizeLarge,
              text: 'proceed'.tr,
              onTap: () {
                if(formKey.currentState!.validate()){
                  Get.toNamed(RouteHelper.getPinSetRoute(
                    signUpBody: SignUpBodyModel(
                      fName: fNameTextController.text,
                      lName: lNameTextController.text,
                      email: emailTextController.text,
                      occupation: occupationTextController.text,
                    ),
                  ));
                }

              },
            );
          })),
          const SizedBox(height: Dimensions.paddingSizeDefault),
        ]),
      ),
    );
  }

  Future _onWillPop(BuildContext context) async {
    DialogHelper.showAnimatedDialog(context, CustomDialogWidget(
        icon: Icons.clear,
        title: 'alert'.tr,
        description: 'your_information_will_remove'.tr,
        isFailed: true,
        onTapFalseText: 'no'.tr,
        onTapTrueText: 'yes'.tr,
        onTapFalse: ()=> Get.back(),
        onTapTrue: (){
          Get.find<CameraScreenController>().removeImage();
          return Get.offAllNamed(RouteHelper.getSplashRoute());
        }),
      dismissible: false,
      isFlip: true,
    );
  }
}
