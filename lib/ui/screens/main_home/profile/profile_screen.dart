import 'package:expense_tracker/main.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shimmer/shimmer.dart';

import '../../../../modals/local_modal/profile_screen_modal.dart';
import '../../../../utils/colors.dart';
import '../../../../utils/custom_icons.dart';
import '../../../../utils/dimens.dart';
import 'profile_bloc.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  ProfileBloc? _profileBloc;

  ProfileBloc get profileBloc => _profileBloc!;

  @override
  void didChangeDependencies() {
    /// dependencies change more than once over a screen's life, and the
    /// feature labels are rebuilt here so they follow the locale. Each rebuild
    /// used to strand the previous bloc with its auth listener still attached.
    _profileBloc?.dispose();
    _profileBloc = ProfileBloc(context: context);

    // Todo: Add this at bloc
    profileBloc.getProfileFeatureList();
    profileBloc.getBasicDetails();

    super.didChangeDependencies();
  }

  @override
  void dispose() {
    _profileBloc?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: white60,
        toolbarHeight: screenHeight * 0.05,
      ),
      backgroundColor: white60,
      body: Padding(
        padding: EdgeInsetsDirectional.symmetric(horizontal: screenWidth * 0.05),
        child: SingleChildScrollView(
          physics: const NeverScrollableScrollPhysics(),
          child: Column(
            children: [
              StreamBuilder<UserDetails>(
                  stream: profileBloc.getBasicUserDetails,
                  builder: (context, snapshot) {
                    return Row(
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        Flexible(
                          fit: FlexFit.loose,
                          child: Container(
                            width: averageScreenSize * 0.175,
                            height: averageScreenSize * 0.175,
                            padding: EdgeInsetsDirectional.all(averageScreenSize * 0.005),
                            margin: EdgeInsetsDirectional.only(end: screenWidth * 0.03),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: violet80,
                                width: averageScreenSize * 0.004,
                              ),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadiusDirectional.circular(averageScreenSize * 0.1),
                              child: snapshot.hasData
                                  ? Image.network(
                                      snapshot.data!.profileUrl,
                                      fit: BoxFit.cover,
                                    )
                                  : Shimmer.fromColors(
                                      baseColor: shimmerBaseColor,
                                      highlightColor: shimmerHighlightColor,
                                      child: CircleAvatar(
                                        radius: averageScreenSize * 0.1,
                                        foregroundColor: black100,
                                        backgroundColor: black100,
                                      ),
                                    ),
                            ),
                          ),
                        ),
                        Row(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            ConstrainedBox(
                              constraints: BoxConstraints.tightFor(
                                width: screenWidth * 0.45,
                                height: averageScreenSize * 0.175,
                              ),
                              child: Column(
                                mainAxisSize: MainAxisSize.max,
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    languages.userName,
                                    style: GoogleFonts.inter(
                                      color: white20,
                                      fontWeight: FontWeight.w500,
                                      fontSize: averageScreenSize * 0.025,
                                    ),
                                  ),
                                  snapshot.hasData
                                      ? Text(
                                          snapshot.hasData ? snapshot.data!.name : languages.setYourName,
                                          style: GoogleFonts.inter(
                                            color: black75,
                                            fontWeight: FontWeight.w600,
                                            fontSize: averageScreenSize * 0.045,
                                          ),
                                        )
                                      : Shimmer.fromColors(
                                          baseColor: shimmerBaseColor,
                                          highlightColor: shimmerHighlightColor,
                                          child: Container(
                                            width: screenWidth * 0.4,
                                            height: screenHeight * 0.035,
                                            decoration: BoxDecoration(
                                              color: black100,
                                              borderRadius: BorderRadius.circular(averageScreenSize * 0.01),
                                            ),
                                          ),
                                        ),
                                ],
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                profileBloc.editName();
                              },
                              child: Icon(
                                CustomIcons.edit_icons,
                                color: black50,
                                size: averageScreenSize * 0.06,
                              ),
                            )
                          ],
                        ),
                      ],
                    );
                  }),
              SizedBox(height: screenHeight * 0.05),
              Material(
                elevation: averageScreenSize * 0.001,
                borderRadius: BorderRadius.circular(averageScreenSize * 0.03),
                color: white100,
                shadowColor: white60,
                child: Container(
                  constraints: BoxConstraints(
                    minWidth: screenWidth - screenWidth * 0.1,
                    maxWidth: screenWidth - screenWidth * 0.1,
                  ),
                  child: ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    padding: EdgeInsetsDirectional.zero,
                    itemCount: profileBloc.profileFeatureOptionList.length,
                    itemBuilder: (context, index) {
                      return Container(
                        constraints: BoxConstraints.expand(height: screenHeight * 0.1, width: screenWidth),
                        padding: EdgeInsetsDirectional.symmetric(horizontal: averageScreenSize * 0.03),
                        child: GestureDetector(
                          behavior: HitTestBehavior.translucent,
                          onTap: profileBloc.profileFeatureOptionList[index].onPressed,
                          child: Row(
                            mainAxisSize: MainAxisSize.max,
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Container(
                                width: averageScreenSize * 0.09,
                                height: averageScreenSize * 0.09,
                                alignment: AlignmentDirectional.center,
                                decoration: BoxDecoration(
                                  color: profileBloc.profileFeatureOptionList[index].iconBG,
                                  borderRadius: BorderRadius.circular(averageScreenSize * 0.03),
                                ),
                                child: Icon(
                                  profileBloc.profileFeatureOptionList[index].iconData,
                                  color: profileBloc.profileFeatureOptionList[index].iconColor,
                                  size: averageScreenSize * 0.05,
                                ),
                              ),
                              SizedBox(width: screenWidth * 0.03),
                              Text(
                                profileBloc.profileFeatureOptionList[index].label,
                                style: GoogleFonts.inter(
                                  color: black50,
                                  fontWeight: FontWeight.w500,
                                  fontSize: averageScreenSize * 0.027,
                                ),
                              )
                            ],
                          ),
                        ),
                      );
                    },
                    separatorBuilder: (context, index) {
                      return Divider(
                        color: white40,
                        thickness: averageScreenSize * 0.002,
                        height: screenHeight * 0.01,
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
