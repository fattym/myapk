import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../providers/auth_provider.dart';
import '../services/api_error.dart';
import 'privacy_policy_screen.dart';

class AccountScreen extends StatefulWidget {
  const AccountScreen({super.key});

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  final _form = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _phone = TextEditingController();
  final _password = TextEditingController();
  final _confirm = TextEditingController();
  bool _register = false;
  bool _showPassword = false;
  bool _busy = false;
  String? _error;

  @override
  void dispose() {
    for (final c in [_name, _email, _phone, _password, _confirm]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_form.currentState!.validate()) return;
    final auth = context.read<AuthProvider>();
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      if (_register) {
        await auth.register(
          name: _name.text.trim(),
          email: _email.text.trim(),
          password: _password.text,
          passwordConfirmation: _confirm.text,
          phone: _phone.text.trim().isEmpty ? null : _phone.text.trim(),
          device: 'mybidhaa-app',
        );
      } else {
        await auth.login(
          email: _email.text.trim(),
          password: _password.text,
          device: 'mybidhaa-app',
        );
      }
      if (mounted) Navigator.of(context).maybePop();
    } on ApiError catch (e) {
      final fields = <String>[
        for (final v in (e.errors ?? const {}).values)
          if (v is List) ...v.map((x) => x.toString()) else v.toString(),
      ];
      if (mounted) {
        setState(() => _error = fields.isNotEmpty ? fields.join('\n') : e.message);
      }
    } catch (_) {
      if (mounted) {
        setState(() => _error =
            'Could not reach MyBidhaa. Check your connection and try again.');
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  String? _required(String? v) =>
      (v == null || v.trim().isEmpty) ? 'Required' : null;

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    return Scaffold(
      appBar: AppBar(title: const Text('Account')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          if (auth.isAuthenticated) ..._signedIn(auth) else ..._authForm(),
          const SizedBox(height: 16),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.privacy_tip_outlined),
            title: const Text('Privacy Policy'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Navigator.of(context).push(MaterialPageRoute(
                builder: (_) => const PrivacyPolicyScreen())),
          ),
        ],
      ),
    );
  }

  List<Widget> _signedIn(AuthProvider auth) => [
        Text(auth.user?.name ?? 'Signed in',
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
        if (auth.user?.email != null) Text(auth.user!.email),
        const SizedBox(height: 16),
        OutlinedButton(
          onPressed: () => auth.logout(),
          child: const Text('Log out'),
        ),
      ];

  List<Widget> _authForm() => [
        Form(
          key: _form,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(_register ? 'Create account' : 'Log in',
                  style: const TextStyle(
                      fontSize: 22, fontWeight: FontWeight.w700)),
              const SizedBox(height: 16),
              if (_register) ...[
                TextFormField(
                    controller: _name,
                    decoration: const InputDecoration(labelText: 'Full name'),
                    validator: _required),
                TextFormField(
                    controller: _phone,
                    keyboardType: TextInputType.phone,
                    decoration:
                        const InputDecoration(labelText: 'Phone (optional)')),
              ],
              TextFormField(
                  controller: _email,
                  keyboardType: TextInputType.emailAddress,
                  autofillHints: const [AutofillHints.email],
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(labelText: 'Email'),
                  validator: (v) => (v == null || !v.contains('@'))
                      ? 'Enter a valid email'
                      : null),
              TextFormField(
                  controller: _password,
                  obscureText: !_showPassword,
                  autofillHints: [
                    _register
                        ? AutofillHints.newPassword
                        : AutofillHints.password
                  ],
                  textInputAction: _register
                      ? TextInputAction.next
                      : TextInputAction.done,
                  onFieldSubmitted: (_) {
                    if (!_register && !_busy) _submit();
                  },
                  decoration: InputDecoration(
                    labelText: 'Password',
                    suffixIcon: IconButton(
                      icon: Icon(_showPassword
                          ? Icons.visibility_off
                          : Icons.visibility),
                      onPressed: () =>
                          setState(() => _showPassword = !_showPassword),
                    ),
                  ),
                  validator: (v) => (v == null || v.length < 6)
                      ? 'At least 6 characters'
                      : null),
              if (_register)
                TextFormField(
                    controller: _confirm,
                    obscureText: !_showPassword,
                    textInputAction: TextInputAction.done,
                    onFieldSubmitted: (_) {
                      if (!_busy) _submit();
                    },
                    decoration:
                        const InputDecoration(labelText: 'Confirm password'),
                    validator: (v) =>
                        v != _password.text ? 'Passwords do not match' : null),
              if (_error != null)
                Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: Text(_error!,
                      style: TextStyle(
                          color: Theme.of(context).colorScheme.error)),
                ),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: _busy ? null : _submit,
                child: _busy
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2))
                    : Text(_register ? 'Create account' : 'Log in'),
              ),
              if (!_register)
                TextButton(
                  onPressed: () => launchUrl(
                      Uri.parse('https://mybidhaa.com/password/reset'),
                      mode: LaunchMode.externalApplication),
                  child: const Text('Forgot password?'),
                ),
              TextButton(
                onPressed: () => setState(() {
                  _register = !_register;
                  _error = null;
                }),
                child: Text(_register
                    ? 'Already have an account? Log in'
                    : 'New here? Create an account'),
              ),
            ],
          ),
        ),
      ];
}
