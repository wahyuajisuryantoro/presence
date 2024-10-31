import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/constants/variables.dart';
import '../../../core/core.dart';
import '../../auth/bloc/logout/logout_bloc.dart';
import '../../auth/pages/login_page.dart';
import '../bloc/get_user/get_user_bloc.dart';
import 'update_profile_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  @override
  void initState() {
    super.initState();
    context.read<GetUserBloc>().add(const GetUserEvent.getUser());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Expanded(
              child: BlocBuilder<GetUserBloc, GetUserState>(
                builder: (context, state) {
                  return state.maybeWhen(orElse: () {
                    return SizedBox.shrink();
                  }, loading: () {
                    return Center(
                      child: CircularProgressIndicator(),
                    );
                  }, success: (user) {
                    return ListView(
                      children: [
                        user.imageUrl != null
                            ? CircleAvatar(
                                radius: 80,
                                backgroundImage: NetworkImage(
                                    "${Variables.baseUrl}/storage/${user.imageUrl}"),
                              )
                            : CircleAvatar(
                                radius: 80,
                                backgroundImage:
                                    AssetImage(Assets.icons.image.path),
                              ),
                        SpaceHeight(24),
                        CustomTextField(
                          readOnly: true,
                          label: 'Name',
                          controller: TextEditingController(text: user.name),
                        ),
                        SpaceHeight(16),
                        CustomTextField(
                          readOnly: true,
                          label: 'Email',
                          controller: TextEditingController(text: user.email),
                        ),
                        SpaceHeight(16),
                        CustomTextField(
                          readOnly: true,
                          label: 'Phone',
                          controller:
                              TextEditingController(text: user.phone ?? '-'),
                        ),
                        SpaceHeight(24),
                        Button.outlined(
                          onPressed: () {
                            context.push(UpdateProfilePage(user: user));
                          },
                          label: 'Update Profile',
                          fontSize: 16.0,
                          height: 48,
                        ),
                        SpaceHeight(16),
                      ],
                    );
                  });
                },
              ),
            ),
            BlocConsumer<LogoutBloc, LogoutState>(
              listener: (context, state) {
                state.maybeMap(
                  orElse: () {},
                  success: (_) {
                    context.pushReplacement(const LoginPage());
                  },
                  error: (value) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(value.error),
                        backgroundColor: AppColors.red,
                      ),
                    );
                  },
                );
              },
              builder: (context, state) {
                return state.maybeWhen(
                  orElse: () {
                    return Button.filled(
                      height: 48,
                      fontSize: 16.0,
                      color: AppColors.red,
                      onPressed: () {
                        context
                            .read<LogoutBloc>()
                            .add(const LogoutEvent.logout());
                      },
                      label: 'Logout',
                    );
                  },
                  loading: () {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  },
                );
              },
            )
          ],
        ),
      ),
    );
  }
}
