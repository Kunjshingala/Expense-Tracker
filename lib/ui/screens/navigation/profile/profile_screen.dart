import 'package:expense_tracker/ui/screens/navigation/profile/profile_bloc.dart';
import 'package:expense_tracker/utils/colors.dart';
import 'package:expense_tracker/utils/dimens.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shimmer/shimmer.dart';

import '../../../../modals/local_modal/profile_screen_modal.dart';
import '../../../../utils/custom_icons.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late ProfileBloc profileBloc;

  @override
  void didChangeDependencies() {
    // TODO: implement didChangeDependencies
    super.didChangeDependencies();
    profileBloc = ProfileBloc(context: context);

    profileBloc.getProfileFeatureList();
    profileBloc.getBasicDetails();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: light60Color,
        toolbarHeight: screenHeight * 0.05,
      ),
      backgroundColor: light60Color,
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
                                color: violet80Color,
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
                                        foregroundColor: dark100Color,
                                        backgroundColor: dark100Color,
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
                                    'UserName',
                                    style: GoogleFonts.inter(
                                      color: light20Color,
                                      fontWeight: FontWeight.w500,
                                      fontSize: averageScreenSize * 0.025,
                                    ),
                                  ),
                                  snapshot.hasData
                                      ? Text(
                                          snapshot.hasData ? snapshot.data!.name : 'Set your name',
                                          style: GoogleFonts.inter(
                                            color: dark75Color,
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
                                              color: dark100Color,
                                              borderRadius: BorderRadius.circular(averageScreenSize * 0.01),
                                            ),
                                          ),
                                        ),
                                ],
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                debugPrint(
                                    '--------------------------------------------------------------------> EditAccount Icon Tap');
                                profileBloc.editName();
                              },
                              child: Icon(
                                CustomIcons.edit_icons,
                                color: dark50Color,
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
                color: light100Color,
                shadowColor: light60Color,
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
                                  color: dark50Color,
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
                        color: light40Color,
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
