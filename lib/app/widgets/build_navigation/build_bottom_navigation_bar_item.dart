import 'package:bpr_ams/app/common/constant/app_colors.dart';
import 'package:bpr_ams/app/data/main/bottom_navigation/bottom_navigation_item_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

class BuildBottomNavigationBarItem extends StatelessWidget {
  final bool isActive;
  final BottomNavigationItemModel data;
  final int index;

  const BuildBottomNavigationBarItem({super.key, required this.isActive, required this.data, required this.index});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: data.onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SvgPicture.asset(height: 20.h, data.iconPath, color: isActive ? data.iconColor : MainColor.greyLightActive),
          const SizedBox(height: 4),
          Text(
            data.label,
            style: data.labelStyle.copyWith(color: isActive ? data.labelStyle.color : MainColor.greyLightActive),
          ),
        ],
      ),
    );
  }
}
