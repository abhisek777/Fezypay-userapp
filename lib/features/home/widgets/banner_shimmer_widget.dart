import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
class BannerShimmerWidget extends StatelessWidget {
  const BannerShimmerWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    return Shimmer.fromColors(
      baseColor: Colors.grey,
      highlightColor: Colors.grey[200]!,
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Container(
            height: 90,
            width: size.width*0.9,
            decoration: BoxDecoration(
              color: Colors.black38,
              borderRadius: BorderRadius.circular(10),
            ),

        ),
      ),
    );
  }
}
