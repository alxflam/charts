// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import 'package:example/gallery_scaffold.dart';
import 'package:flutter/material.dart';

class GalleryScaffoldGroup extends StatelessWidget {
  final Widget listTileIcon;
  final String title;
  final List<GalleryScaffold> children;

  const GalleryScaffoldGroup({
    super.key,
    required this.listTileIcon,
    required this.title,
    required this.children,
  });

  Widget buildGalleryGroupListTile(BuildContext context) => ListTile(
      leading: listTileIcon,
      title: Text(title),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => this),
        );
      });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text(title)),
        body: ListView(
          padding: kMaterialListPadding,
          children:
              children.map((a) => a.buildGalleryListTile(context)).toList(),
        ));
  }
}
