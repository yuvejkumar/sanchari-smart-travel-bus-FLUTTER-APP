import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
//import 'package:shared_preferences/shared_preferences.dart';
import 'dart:math'; 
//import 'dart:convert'; // Required for jsonEncode/jsonDecode
import 'package:share_plus/share_plus.dart'; // <-- Import the share package
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:firebase_auth/firebase_auth.dart'; // 1. Import Firebase Auth
import 'package:cloud_firestore/cloud_firestore.dart';

Future<void> main() async {
  // Ensure that Flutter is initialized
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  // Run your app using YOUR app's class name
  runApp(SanchariApp()); 
}
//സഞ്ചാരി
class SanchariApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sanchari (സഞ്ചാരി)',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        primaryColor: Color(0xFF1976D2),
        colorScheme: ColorScheme.fromSeed(
          seedColor: Color(0xFF1976D2),
          secondary: Color(0xFF03DAC6),
        ),
        visualDensity: VisualDensity.adaptivePlatformDensity,
        appBarTheme: AppBarTheme(
          backgroundColor: Color(0xFF1976D2),
          foregroundColor: Colors.white,
          elevation: 0,
        ),
      ),
      home: AuthWrapper(),
      routes: {
        '/home': (context) => HomePage(),
        '/route-planner': (context) => RoutePlannerPage(),
        '/live-tracking': (context) => LiveTrackingPage(),
        '/places': (context) => PlacesPage(), // <-- ADD THIS NEW LINE
        '/tickets': (context) => TicketsPage(),
        '/safety': (context) => SafetyPage(),
        '/emergency_contacts': (context) => EmergencyContactsPage(), // <-- ADD THIS NEW ROUTE
        '/feedback': (context) => FeedbackPage(),
        '/rewards': (context) => RewardsPage(),
        '/profile': (context) => ProfilePage(),
        '/notifications': (context) => NotificationsPage(), // <-- ADD THIS NEW ROUTE
        '/edit_profile': (context) => EditProfilePage(), // <-- ADD THIS NEW ROUTE
        '/register': (context) => RegisterPage(),
        '/login': (context) => LoginPage(),
      },
    );
  }
}



// 2. The class can now be a StatelessWidget, as it doesn't need to manage its own state.
//    The StreamBuilder will handle all the state changes for us.
class AuthWrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // 3. StreamBuilder is the key widget here. It listens to a stream of events.
    return StreamBuilder<User?>(
      // 4. This is the stream from Firebase Auth. It will automatically send a new event
      //    whenever a user logs in or logs out.
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        
        // --- State 1: The connection is still loading ---
        // While the app is checking with Firebase for the first time.
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        // --- State 2: A user is successfully logged in ---
        // The 'snapshot' has data, which is the Firebase User object.
        if (snapshot.hasData) {
          // If a user is logged in, show the HomePage.
          return HomePage();
        }

        // --- State 3: No user is logged in ---
        // The 'snapshot' has no data.
        else {
          // If no user is logged in, show the LoginPage.
          return LoginPage();
        }
      },
    );
  }
}


// (This class should be inside your main.dart file)

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();

  // --- CHANGE 1: Switched from phone to email controller ---
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isLoading = false;
  bool _isPasswordVisible = false;

  @override
  void dispose() {
    // --- CHANGE 2: Disposing the new email controller ---
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        // ... your beautiful UI gradient and layout ...
        // ... (This part is unchanged) ...
        // The only change in the build method is inside the Form
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue.shade200, Colors.blue.shade500],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Icon(Icons.lock_open_rounded, size: 80, color: Colors.white),
                  const SizedBox(height: 16),
                  Text('Welcome Back!', textAlign: TextAlign.center, style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white)),
                  const SizedBox(height: 8),
                  Text('Sign in to continue', textAlign: TextAlign.center, style: TextStyle(fontSize: 16, color: Colors.white70)),
                  const SizedBox(height: 48),
                  Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        // --- CHANGE 3: The phone field is replaced with an email field ---
                        _buildEmailField(),
                        const SizedBox(height: 16),
                        _buildPasswordField(), // This widget is unchanged
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  _buildLoginButton(),   // This widget is unchanged
                  const SizedBox(height: 24),
                  _buildRegisterLink(),  // This widget is unchanged
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // --- CHANGE 4: A new widget for the email field ---
  Widget _buildEmailField() {
    return TextFormField(
      controller: _emailController,
      keyboardType: TextInputType.emailAddress, // Use email keyboard type
      style: TextStyle(color: Colors.black87),
      decoration: InputDecoration(
        labelText: 'Email Address', // Updated label
        prefixIcon: Icon(Icons.email, color: Colors.grey.shade700), // Updated icon
        filled: true,
        fillColor: Colors.white.withOpacity(0.9),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter your email address';
        }
        // Simple email validation
        if (!value.contains('@') || !value.contains('.')) {
          return 'Please enter a valid email address';
        }
        return null;
      },
    );
  }

  // _buildPasswordField, _buildLoginButton, and _buildRegisterLink methods are unchanged
  // You can keep them exactly as they are.
  Widget _buildPasswordField() {
    // ... no changes needed here
    return TextFormField(
      controller: _passwordController,
      obscureText: !_isPasswordVisible,
      style: TextStyle(color: Colors.black87),
      decoration: InputDecoration(
        labelText: 'Password',
        prefixIcon: Icon(Icons.lock, color: Colors.grey.shade700),
        suffixIcon: IconButton(
          icon: Icon(
            _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
            color: Colors.grey.shade700,
          ),
          onPressed: () {
            setState(() {
              _isPasswordVisible = !_isPasswordVisible;
            });
          },
        ),
        filled: true,
        fillColor: Colors.white.withOpacity(0.9),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter your password';
        }
        if (value.length < 6) {
          return 'Password must be at least 6 characters';
        }
        return null;
      },
    );
  }

  Widget _buildLoginButton() {
    // ... no changes needed here
    return _isLoading
        ? Center(child: CircularProgressIndicator(color: Colors.white))
        : ElevatedButton(
            onPressed: _login,
            child: Text('Login', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            style: ElevatedButton.styleFrom(
              padding: EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              backgroundColor: Colors.blue.shade800,
              foregroundColor: Colors.white,
            ),
          );
  }

  Widget _buildRegisterLink() {
    // ... no changes needed here
     return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text("Don't have an account? ", style: TextStyle(color: Colors.white70)),
        GestureDetector(
          onTap: () {
            Navigator.pushNamed(context, '/register');
          },
          child: Text('Register', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, decoration: TextDecoration.underline)),
        ),
      ],
    );
  }


  // --- CHANGE 5: The ENTIRE _login method is replaced with Firebase logic ---
  void _login() async {
    // First, validate the form. If it's not valid, do nothing.
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Use Firebase to sign in with email and password
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text.trim(), // Use trim() to remove leading/trailing spaces
        password: _passwordController.text.trim(),
      );
      
      // If login is successful, the AuthWrapper will automatically navigate
      // to the HomePage. We don't need to call Navigator.push here anymore.

    } on FirebaseAuthException catch (e) {
      // Handle specific Firebase authentication errors
      String message = 'An error occurred. Please check your credentials.';
      if (e.code == 'user-not-found') {
        message = 'No user found for that email.';
      } else if (e.code == 'wrong-password') {
        message = 'Wrong password provided for that user.';
      } else if (e.code == 'invalid-email') {
        message = 'The email address is not valid.';
      }
      
      // Show a user-friendly error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red,
        ),
      );
    } catch (e) {
      // Handle other potential errors
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('An unexpected error occurred. Please try again.'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      // ALWAYS ensure the loading indicator is turned off
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}


// (This class should be inside your main.dart file)


class RegisterPage extends StatefulWidget {
  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  
  // --- CHANGE 1: Adjusted controllers for the new flow ---
  final _nameController = TextEditingController();
  final _emailController = TextEditingController(); // Email is now mandatory
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  // We can remove the phone controller for now to keep registration simple.
  // It can be added later in the "Edit Profile" section.
  
  bool _isLoading = false;

  @override
  void dispose() {
    // --- CHANGE 2: Disposing correct controllers ---
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Create Account')), // A more fitting title
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView( // Using ListView is great for scrollability
            children: [
              // --- CHANGE 3: The form fields are updated ---
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(labelText: 'Full Name', prefixIcon: Icon(Icons.person)),
                validator: (value) => value!.isEmpty ? 'Please enter your name' : null,
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(labelText: 'Email Address', prefixIcon: Icon(Icons.email)),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Please enter an email';
                  if (!value.contains('@')) return 'Please enter a valid email';
                  return null;
                },
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _passwordController,
                decoration: InputDecoration(labelText: 'Password', prefixIcon: Icon(Icons.lock)),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Please enter a password';
                  if (value.length < 6) return 'Password must be at least 6 characters';
                  return null;
                },
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _confirmPasswordController,
                decoration: InputDecoration(labelText: 'Confirm Password', prefixIcon: Icon(Icons.lock)),
                obscureText: true,
                validator: (value) {
                  if (value != _passwordController.text) return 'Passwords do not match';
                  return null;
                },
              ),
              SizedBox(height: 24),
              _isLoading
                  ? Center(child: CircularProgressIndicator()) // Center the indicator
                  : ElevatedButton(
                      onPressed: _register,
                      child: Text('Register'),
                      style: ElevatedButton.styleFrom(minimumSize: Size(double.infinity, 50)),
                    ),
              SizedBox(height: 16),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Already have an account? Login'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- CHANGE 4: The ENTIRE _register method is replaced with Firebase logic ---
  void _register() async {
    // Validate the form first
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Step 1: Create the user in Firebase Authentication
      UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      // Check if the user was created successfully
      User? newUser = userCredential.user;
      
      if (newUser != null) {
        // Step 2: Create a corresponding user profile document in Firestore
        await FirebaseFirestore.instance
            .collection('users') // Go to the 'users' collection
            .doc(newUser.uid)    // Create a new document with the user's unique ID
            .set({               // Set the data for this user
              'name': _nameController.text.trim(),
              'email': _emailController.text.trim(),
              'createdAt': Timestamp.now(), // Good practice to store creation time
              'rewardPoints': 100, // Award a starting bonus of 100 points
            });
      }
      
      // If registration is successful, the AuthWrapper will automatically handle
      // navigation to the HomePage. We don't need a Navigator.push here.

    } on FirebaseAuthException catch (e) {
      // Handle Firebase-specific errors
      String message = 'An error occurred during registration.';
      if (e.code == 'weak-password') {
        message = 'The password provided is too weak.';
      } else if (e.code == 'email-already-in-use') {
        message = 'An account already exists for that email.';
      } else if (e.code == 'invalid-email') {
        message = 'The email address is not valid.';
      }
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), backgroundColor: Colors.red),
      );

    } catch (e) {
      // Handle any other errors
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('An unexpected error occurred.'), backgroundColor: Colors.red),
      );
    } finally {
      // Always turn off the loading indicator
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}



// (This class should be inside your main.dart file)


class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {

  // The logout method is now much simpler.
  void _logout() async {
    // Just sign out from Firebase. The AuthWrapper will handle navigating to the LoginPage.
    await FirebaseAuth.instance.signOut();
    
    // It's good practice to pop all routes from the navigator stack.
    // This prevents the user from pressing the "back" button and returning to a logged-in screen.
    if (mounted) {
      Navigator.of(context).popUntil((route) => route.isFirst);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Get the current user from Firebase Authentication.
    final User? currentUser = FirebaseAuth.instance.currentUser;

    // A safety check. This screen should not be reachable if the user is not logged in,
    // but it's good practice to handle this edge case.
    if (currentUser == null) {
      return Scaffold(body: Center(child: Text("You are not logged in.")));
    }
    
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text('My Profile'),
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.black,
      ),
      // StreamBuilder will listen for any changes to the user's document in Firestore.
      // This gives us LIVE updates.
      body: StreamBuilder<DocumentSnapshot>(
        // Point it to the 'users' collection and the document with the current user's unique ID.
        stream: FirebaseFirestore.instance.collection('users').doc(currentUser.uid).snapshots(),
        builder: (context, snapshot) {
          
          // State 1: Still loading data from Firestore.
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          // State 2: Error fetching data.
          if (snapshot.hasError) {
            return Center(child: Text("Something went wrong!"));
          }

          // State 3: User document doesn't exist.
          if (!snapshot.hasData || !snapshot.data!.exists) {
            return Center(child: Text("User profile not found."));
          }

          // State 4: Data has been successfully loaded!
          // We cast the data to a Map to easily access its fields.
          final userData = snapshot.data!.data() as Map<String, dynamic>;

          // Now we build the UI using the live data from the `userData` map.
          return SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              children: [
                _buildProfileHeader(userData),
                SizedBox(height: 24),
                _buildMenuItems(userData),
                SizedBox(height: 24),
                _buildLogoutButton(),
              ],
            ),
          );
        },
      ),
    );
  }

  // This build method now accepts the `userData` map to display live data.
  Widget _buildProfileHeader(Map<String, dynamic> userData) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            CircleAvatar(
              radius: 50,
              backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
              child: Icon(Icons.person, size: 60, color: Theme.of(context).primaryColor),
            ),
            SizedBox(height: 16),
            Text(
              // Use data from the map, with a fallback '??' in case a field is missing.
              userData['name'] ?? 'No Name',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 4),
            Text(
              userData['email'] ?? 'No Email',
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
            // We will add the phone number field after we update the EditProfilePage.
          ],
        ),
      ),
    );
  }

  // This build method also accepts `userData` to pass it to the edit page.
  Widget _buildMenuItems(Map<String, dynamic> userData) {
    void navigateToEditProfile() {
      // Pass the current user data to the edit page as arguments.
      // After editing, the StreamBuilder on this page will automatically refresh the UI.
      Navigator.pushNamed(context, '/edit_profile', arguments: userData);
    }
    
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Column(
        children: [
          _buildMenuTile(
            icon: Icons.stars,
            color: Colors.amber,
            title: 'Reward Points',
            subtitle: '${userData['rewardPoints'] ?? 0} points earned',
            onTap: () => Navigator.pushNamed(context, '/rewards'),
          ),
          Divider(height: 1),
          _buildMenuTile(
            icon: Icons.history,
            color: Colors.blue,
            title: 'Trip History',
            subtitle: 'View your past journeys',
            onTap: () => Navigator.pushNamed(context, '/tickets'),
          ),
          Divider(height: 1),
          _buildMenuTile(
            icon: Icons.settings,
            color: Colors.grey,
            title: 'Settings',
            subtitle: 'Manage your profile details',
            onTap: navigateToEditProfile,
          ),
        ],
      ),
    );
  }

  // This is a helper widget and is complete.
  Widget _buildMenuTile({
    required IconData icon,
    required Color color,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: color, size: 28),
      title: Text(title, style: TextStyle(fontWeight: FontWeight.w500)),
      subtitle: Text(subtitle, style: TextStyle(color: Colors.grey[600])),
      trailing: Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
    );
  }

  // This is a helper widget and is complete.
  Widget _buildLogoutButton() {
    return ElevatedButton.icon(
      onPressed: _logout, // Calls the new, simplified logout function
      icon: Icon(Icons.logout),
      label: Text('Logout'),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.red.shade400,
        foregroundColor: Colors.white,
        minimumSize: Size(double.infinity, 50),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}


// (This class should be inside your main.dart file)


class EditProfilePage extends StatefulWidget {
  @override
  _EditProfilePageState createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  
  // Controllers for the fields the user can edit
  late TextEditingController _nameController;
  late TextEditingController _phoneController; // Added a controller for the phone number
  
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _phoneController = TextEditingController();
    
    // This is a safe way to access the arguments passed to this page
    // It runs after the first frame has been built.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Get the user data that was passed from the ProfilePage
      final userData = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
      
      // Pre-fill the text fields with the user's current data
      _nameController.text = userData['name'] ?? '';
      _phoneController.text = userData['phone'] ?? ''; // Added phone number
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose(); // Dispose the new controller
    super.dispose();
  }

  // --- THIS IS THE CORE CHANGE: Saving data to Firestore ---
  Future<void> _saveProfile() async {
    // Validate the form
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Get the current user's unique ID from Firebase Auth
      final String? uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) {
        throw Exception("User is not logged in.");
      }

      // Prepare the data to be updated in Firestore
      final Map<String, dynamic> updatedData = {
        'name': _nameController.text.trim(),
        'phone': _phoneController.text.trim(),
        // Note: We don't update the email here. Changing the login email is a more
        // complex and sensitive operation, best left out for now.
      };

      // Get a reference to the user's document and update it
      await FirebaseFirestore.instance.collection('users').doc(uid).update(updatedData);

      // Show a success message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Profile updated successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        
        // Go back to the previous screen (ProfilePage)
        Navigator.pop(context);
      }

    } catch (e) {
      // Show an error message if something goes wrong
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update profile: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Retrieve the user's email from the arguments to display as read-only
    final userData = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    final email = userData['email'];

    return Scaffold(
      appBar: AppBar(title: Text('Edit Profile')),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Full Name',
                  prefixIcon: Icon(Icons.person_outline),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                validator: (value) => value!.isEmpty ? 'Please enter your name' : null,
              ),
              SizedBox(height: 16),
              // --- NEW FIELD: Phone Number is now editable ---
              TextFormField(
                controller: _phoneController,
                decoration: InputDecoration(
                  labelText: 'Phone Number',
                  prefixIcon: Icon(Icons.phone_outlined),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (value != null && value.isNotEmpty && value.length != 10) {
                    return 'Please enter a valid 10-digit phone number';
                  }
                  return null; // Phone number can be optional
                },
              ),
              SizedBox(height: 16),
              // Display email address as read-only
              TextFormField(
                initialValue: email,
                readOnly: true,
                decoration: InputDecoration(
                  labelText: 'Email Address (Cannot be changed)',
                  prefixIcon: Icon(Icons.email_outlined),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  filled: true,
                  fillColor: Colors.grey[200],
                ),
              ),
              SizedBox(height: 32),
              _isLoading
                  ? Center(child: CircularProgressIndicator())
                  : ElevatedButton.icon(
                      onPressed: _saveProfile,
                      icon: Icon(Icons.save),
                      label: Text('Save Changes'),
                     
                    // NEW & CORRECTED CODE
                      style: ButtonStyle(
                        padding: MaterialStateProperty.all(EdgeInsets.symmetric(vertical: 16)),
                        shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                          RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
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






class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;
  
  final List<Widget> _pages = [
    HomeContent(),
    TicketsPage(),
    LiveTrackingPage(),
    RewardsPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Sanchari (സഞ്ചാരി)', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: Icon(Icons.notifications),
            onPressed: () => Navigator.pushNamed(context, '/notifications'),
          ),
          IconButton(
            icon: Icon(Icons.account_circle),
            onPressed: () => Navigator.pushNamed(context, '/profile'),
          ),
        ],
      ),
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Theme.of(context).primaryColor,
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.confirmation_number), label: 'Tickets'),
          BottomNavigationBarItem(icon: Icon(Icons.track_changes), label: 'Track'),
          BottomNavigationBarItem(icon: Icon(Icons.stars), label: 'Rewards'),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.pushNamed(context, '/safety'),
        child: Icon(Icons.emergency),
        backgroundColor: Colors.red,
        tooltip: 'Emergency SOS',
      ),
    );
  }

}


// (This class should be in your main.dart file)

class NotificationsPage extends StatefulWidget { // Changed to StatefulWidget
  @override
  _NotificationsPageState createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {

  // A helper function to get the right icon and color based on notification type
  Map<String, dynamic> _getNotificationAppearance(String type) {
    switch (type) {
      case 'booking_success':
        return {'icon': Icons.confirmation_number, 'color': Colors.green};
      case 'reward_earned':
        return {'icon': Icons.stars, 'color': Colors.amber};
      case 'delay_alert':
        return {'icon': Icons.bus_alert, 'color': Colors.orange};
      default:
        return {'icon': Icons.notifications, 'color': Colors.blue};
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return Scaffold(
        appBar: AppBar(title: Text('Notifications')),
        body: Center(child: Text("Please log in to see notifications.")),
      );
    }

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text('Notifications'),
      ),
      // Use a StreamBuilder to get live notifications for the current user
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('notifications')
            .where('userId', isEqualTo: user.uid)
            .orderBy('createdAt', descending: true) // Show newest first
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return _buildEmptyState();
          }

          final notifications = snapshot.data!.docs;
          
          return ListView.builder(
            padding: EdgeInsets.all(8.0),
            itemCount: notifications.length,
            itemBuilder: (context, index) {
              final notificationData = notifications[index].data() as Map<String, dynamic>;
              return _buildNotificationItem(context, notificationData);
            },
          );
        },
      ),
    );
  }

  Widget _buildNotificationItem(BuildContext context, Map<String, dynamic> notification) {
    final appearance = _getNotificationAppearance(notification['type'] ?? '');
    final IconData icon = appearance['icon'];
    final Color color = appearance['color'];
    
    // A simple time formatter (for a real app, use the `intl` package)
    String timeAgo = 'Just now';
    if (notification['createdAt'] != null) {
        final DateTime notificationTime = (notification['createdAt'] as Timestamp).toDate();
        final Duration difference = DateTime.now().difference(notificationTime);
        if (difference.inDays > 0) {
            timeAgo = '${difference.inDays}d ago';
        } else if (difference.inHours > 0) {
            timeAgo = '${difference.inHours}h ago';
        } else if (difference.inMinutes > 0) {
            timeAgo = '${difference.inMinutes}m ago';
        }
    }


    return Card(
      margin: EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withOpacity(0.1),
          child: Icon(icon, color: color),
        ),
        title: Text(
          notification['title'] ?? 'No Title',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(notification['subtitle'] ?? ''),
        trailing: Text(
          timeAgo,
          style: TextStyle(color: Colors.grey, fontSize: 12),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.notifications_off_outlined, size: 80, color: Colors.grey),
          SizedBox(height: 16),
          Text(
            'No notifications yet',
            style: TextStyle(fontSize: 18, color: Colors.grey[600]),
          ),
          Text(
            'We\'ll let you know when something important happens.',
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }
}

// (This class should be in your main.dart file)


class HomeContent extends StatelessWidget { // Can be a StatelessWidget now

  // Helper function to determine trip status based on its date
  String _getTripStatus(String dateString) {
    try {
      // Assuming date format is "DD/MM/YYYY"
      final parts = dateString.split('/');
      final day = int.parse(parts[0]);
      final month = int.parse(parts[1]);
      final year = int.parse(parts[2]);
      final ticketDate = DateTime(year, month, day);

      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);

      if (ticketDate.isBefore(today)) {
        return 'Completed';
      } else {
        return 'Upcoming';
      }
    } catch (e) {
      return 'Upcoming'; // Default status if date parsing fails
    }
  }

  @override
  Widget build(BuildContext context) {
    // Get the current user from Firebase Auth
    final User? currentUser = FirebaseAuth.instance.currentUser;

    // A safety check in case this widget is built before a user is logged in.
    if (currentUser == null) {
      return Center(child: Text("Loading user data..."));
    }

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- CHANGE 1: Welcome card now uses a StreamBuilder to get the user's name ---
            StreamBuilder<DocumentSnapshot>(
              stream: FirebaseFirestore.instance.collection('users').doc(currentUser.uid).snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator()); // Show loading while fetching name
                }
                if (!snapshot.hasData || !snapshot.data!.exists) {
                  return _buildWelcomeCard('User'); // Fallback name
                }
                final userData = snapshot.data!.data() as Map<String, dynamic>;
                final userName = userData['name'] ?? 'User';
                return _buildWelcomeCard(userName);
              },
            ),
            SizedBox(height: 24),
            _buildQuickActions(context),
            SizedBox(height: 24),
            _buildRecentTripsSection(context, currentUser.uid),
          ],
        ),
      ),
    );
  }

  // --- CHANGE 2: Welcome card now accepts the user's name as a parameter ---
  Widget _buildWelcomeCard(String userName) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        gradient: LinearGradient(
          colors: [Colors.blue.shade700, Colors.blue.shade400], // Example colors
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Welcome, $userName!', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
          SizedBox(height: 8),
          Text('Ready for your next journey?', style: TextStyle(fontSize: 16, color: Colors.white70)),
        ],
      ),
    );
  }

  // No changes needed for Quick Actions
  Widget _buildQuickActions(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Quick Actions', style: Theme.of(context).textTheme.titleLarge!),
        SizedBox(height: 16),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          childAspectRatio: 1.1,
          children: [
            _buildFeatureCard(context, 'Route Planner', Icons.route, 'Plan & Book', '/route-planner', Colors.blue),
            _buildFeatureCard(context, 'Live Tracking', Icons.location_on, 'Track Your Bus', '/live-tracking', Colors.green),
            _buildFeatureCard(context, 'Places to Visit',Icons.landscape, 'Explore Attractions', '/places', Colors.purple),
            _buildFeatureCard(context, 'Help & Feedback', Icons.feedback, 'Give Feedback', '/feedback', Colors.orange),
          ],
        ),
      ],
    );
  }
  
  // --- CHANGE 3: Recent Trips now uses a StreamBuilder to get ticket data from Firestore ---
  Widget _buildRecentTripsSection(BuildContext context, String uid) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Recent Trips', style: Theme.of(context).textTheme.titleLarge!),
        SizedBox(height: 16),
        StreamBuilder<QuerySnapshot>(
          // The query to get tickets for the currently logged-in user
          stream: FirebaseFirestore.instance
              .collection('tickets')
              .where('userId', isEqualTo: uid)
              .orderBy('bookedAt', descending: true) // Show newest first
              .limit(2) // Only get the 2 most recent tickets
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            }
            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return _buildEmptyTripsCard();
            }
            
            final trips = snapshot.data!.docs;
            return ListView.separated(
              itemCount: trips.length,
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              separatorBuilder: (_, __) => SizedBox(height: 12),
              itemBuilder: (context, index) {
                final tripData = trips[index].data() as Map<String, dynamic>;
                return _buildTripCard(tripData);
              },
            );
          },
        ),
      ],
    );
  }

  // No changes needed for the empty state card
  Widget _buildEmptyTripsCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Center(
          child: Column(
            children: [
              Icon(Icons.directions_bus_outlined, size: 40, color: Colors.grey),
              SizedBox(height: 16),
              Text('No recent trips found.', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
              SizedBox(height: 8),
              Text('Your booked tickets will appear here.', style: TextStyle(color: Colors.grey[600]), textAlign: TextAlign.center),
            ],
          ),
        ),
      ),
    );
  }

  // --- CHANGE 4: The trip card now gets all its data from the Firestore map ---
  Widget _buildTripCard(Map<String, dynamic> trip) {
    // We use fallback values '??' to prevent errors if a field is missing
    final status = _getTripStatus(trip['date'] ?? '01/01/1970');
    final statusColor = status == 'Completed' ? Colors.green : Colors.blue;
    final route = '${trip['source'] ?? 'N/A'} → ${trip['destination'] ?? 'N/A'}';
    final time = '${trip['date'] ?? 'N/A'} at ${trip['departure'] ?? 'N/A'}';

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: statusColor.withOpacity(0.1),
          child: Icon(Icons.directions_bus, color: statusColor),
        ),
        title: Text(route, style: TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(time),
        trailing: Container(
          padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: statusColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(status, style: TextStyle(color: statusColor, fontSize: 12, fontWeight: FontWeight.bold)),
        ),
      ),
    );
  }

  // No changes needed for the feature card
  Widget _buildFeatureCard(BuildContext context, String title, IconData icon, String subtitle, String route, Color color) {
    return InkWell(
      onTap: () => Navigator.pushNamed(context, route),
      borderRadius: BorderRadius.circular(12),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 28,
              backgroundColor: color.withOpacity(0.1),
              child: Icon(icon, size: 30, color: color),
            ),
            SizedBox(height: 12),
            Text(title, style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 4),
            Text(subtitle, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
          ],
        ),
      ),
    );
  }
}

// (This class should be in your main.dart file)


class PlacesPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text('Places to Visit'),
      ),
      // Use a StreamBuilder to get the list of places in real-time
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('places').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text("No places found. Please check back later."));
          }

          final places = snapshot.data!.docs;

          return ListView.builder(
            padding: EdgeInsets.all(12),
            itemCount: places.length,
            itemBuilder: (context, index) {
              final placeData = places[index].data() as Map<String, dynamic>;
              return _buildPlaceCard(context, placeData);
            },
          );
        },
      ),
    );
  }

  // A widget to build a beautiful card for each place
  Widget _buildPlaceCard(BuildContext context, Map<String, dynamic> place) {
    return Card(
      elevation: 4,
      margin: EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      clipBehavior: Clip.antiAlias, // Ensures the image clips to the rounded corners
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image Section
          Image.network(
            place['imageUrl'] ?? 'https://via.placeholder.com/400x200', // A fallback image
            height: 200,
            width: double.infinity,
            fit: BoxFit.cover,
            // Show a loading indicator while the image loads
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return Container(
                height: 200,
                child: Center(child: CircularProgressIndicator()),
              );
            },
            // Show an error icon if the image fails to load
            errorBuilder: (context, error, stackTrace) {
              return Container(
                height: 200,
                color: Colors.grey[200],
                child: Icon(Icons.image_not_supported, color: Colors.grey, size: 50),
              );
            },
          ),
          
          // Details Section
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  place['name'] ?? 'Unnamed Place',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.location_on, size: 16, color: Colors.grey[600]),
                    SizedBox(width: 4),
                    Text(
                      place['location'] ?? 'Unknown Location',
                      style: TextStyle(color: Colors.grey[700], fontSize: 14),
                    ),
                  ],
                ),
                SizedBox(height: 12),
                Text(
                  place['description'] ?? 'No description available.',
                  style: TextStyle(height: 1.5), // Improves readability
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
// (This class should be in your main.dart file)


class RoutePlannerPage extends StatefulWidget {
  @override
  _RoutePlannerPageState createState() => _RoutePlannerPageState();
}

class _RoutePlannerPageState extends State<RoutePlannerPage> {
  final _sourceController = TextEditingController(text: "Kochi");
  final _destController = TextEditingController(text: "Trivandrum");
  DateTime _selectedDate = DateTime.now();
  int _passengerCount = 1;
  bool _isLoading = false;
  List<Map<String, dynamic>> _searchResults = [];

  // Method to swap source and destination (no changes needed)
  void _swapLocations() {
    final temp = _sourceController.text;
    setState(() {
      _sourceController.text = _destController.text;
      _destController.text = temp;
    });
  }
  
  // --- THIS IS THE CORE CHANGE: Searching for buses in Firestore ---
  Future<void> _searchBuses() async {
    // Validate form
    if (_sourceController.text.trim().isEmpty || _destController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please fill in both source and destination')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
      _searchResults = []; // Clear previous results
    });

    try {
      // Get the source and destination, trimming whitespace
      final String source = _sourceController.text.trim();
      final String destination = _destController.text.trim();

      // **The Firestore Query**
      // This query looks for documents in the 'buses' collection where the 'route' array
      // contains BOTH the source and the destination city.
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('buses')
          .where('route', arrayContainsAny: [source, destination])
          .get();
      
      List<Map<String, dynamic>> busesFound = [];
      
      // Since Firestore returns buses that contain EITHER city, we must filter them in Dart.
      for (var doc in querySnapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        final route = List<String>.from(data['route'] ?? []);
        
        // Check if the route contains both cities AND if the source comes before the destination.
        if (route.contains(source) && route.contains(destination) && route.indexOf(source) < route.indexOf(destination)) {
          // Add the bus document ID, which is useful for booking
          data['id'] = doc.id;
          busesFound.add(data);
        }
      }
      
      setState(() {
        _searchResults = busesFound;
      });

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error searching for buses: ${e.toString()}')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Your UI build methods and other logic remain largely the same.
  // The only change is how the data is fetched.
  @override
  Widget build(BuildContext context) {
    // ... no changes needed in the build method
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(title: Text('Plan Your Journey')),
      body: Column(
        children: [
          _buildSearchForm(),
          Expanded(
            child: _isLoading
                ? Center(child: CircularProgressIndicator())
                : _buildSearchResults(),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchForm() {
    // ... no changes needed here
    return Card(
      margin: EdgeInsets.all(12),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Column(
                    children: [
                      TextField(controller: _sourceController, decoration: InputDecoration(labelText: 'From', prefixIcon: Icon(Icons.my_location, color: Colors.green))),
                      SizedBox(height: 12),
                      TextField(controller: _destController, decoration: InputDecoration(labelText: 'To', prefixIcon: Icon(Icons.location_on, color: Colors.red))),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: IconButton(icon: Icon(Icons.swap_vert, color: Colors.blue, size: 32), onPressed: _swapLocations),
                ),
              ],
            ),
            SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  flex: 3,
                  child: InkWell(
                    onTap: _selectDate,
                    child: InputDecorator(
                      decoration: InputDecoration(labelText: 'Date', prefixIcon: Icon(Icons.calendar_today), border: InputBorder.none),
                      child: Text('${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                    ),
                  ),
                ),
                Expanded(flex: 2, child: _buildPassengerSelector()),
              ],
            ),
            SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _searchBuses,
              icon: Icon(Icons.search),
              label: Text('Search Buses'),
              style: ElevatedButton.styleFrom(minimumSize: Size(double.infinity, 50), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPassengerSelector() {
    // ... no changes needed here
     return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(icon: Icon(Icons.remove_circle, color: Colors.red), onPressed: () { if (_passengerCount > 1) setState(() => _passengerCount--); }),
        Text('$_passengerCount', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        IconButton(icon: Icon(Icons.add_circle, color: Colors.green), onPressed: () => setState(() => _passengerCount++)),
      ],
    );
  }

  Widget _buildSearchResults() {
    // ... no changes needed here
    if (_searchResults.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search, size: 80, color: Colors.grey),
            SizedBox(height: 16),
            Text('Find your perfect journey', style: TextStyle(fontSize: 18, color: Colors.grey[600])),
          ],
        ),
      );
    }
    return ListView.builder(
      padding: EdgeInsets.symmetric(horizontal: 12),
      itemCount: _searchResults.length,
      itemBuilder: (context, index) => _buildBusCard(_searchResults[index]),
    );
  }

  Widget _buildBusCard(Map<String, dynamic> bus) {
    // ... no changes needed here
    return Card(
      margin: EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Text(bus['name'], style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              Text('${bus['seats']} seats left', style: TextStyle(color: Colors.orange.shade700, fontWeight: FontWeight.w500)),
            ]),
            Divider(height: 20),
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              _buildTimeInfo('Departure', bus['departure']),
              Icon(Icons.arrow_forward, color: Colors.grey),
              _buildTimeInfo('Arrival', bus['arrival']),
              _buildTimeInfo('Duration', bus['duration']),
            ]),
            SizedBox(height: 16),
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Text('₹${bus['fare']}', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.green)),
              ElevatedButton(onPressed: () => _showBookingSummary(bus), child: Text('Book Now')),
            ]),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeInfo(String label, String time) {
    // ... no changes needed here
    return Column(children: [Text(label, style: TextStyle(color: Colors.grey, fontSize: 12)), Text(time, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16))]);
  }

  void _selectDate() async {
    // ... no changes needed here
    final date = await showDatePicker(context: context, initialDate: _selectedDate, firstDate: DateTime.now().subtract(Duration(days:1)), lastDate: DateTime.now().add(Duration(days: 30)));
    if (date != null) {
      setState(() => _selectedDate = date);
    }
  }
  
  void _showBookingSummary(Map<String, dynamic> bus) {
    // ... no changes needed here
    int totalFare = (bus['fare'] as int) * _passengerCount;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Booking Summary'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Bus: ${bus['name']}', style: TextStyle(fontWeight: FontWeight.bold)),
            Text('Route: ${_sourceController.text} → ${_destController.text}'),
            Text('Passengers: $_passengerCount'),
            Divider(height: 20),
            Text('Total Fare: ₹$totalFare', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.push(context, MaterialPageRoute(builder: (context) => PaymentPage(bookingDetails: {
                ...bus,
                'source': _sourceController.text,
                'destination': _destController.text,
                'passengerCount': _passengerCount,
                'totalFare': totalFare,
                'date': '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
              })));
            },
            child: Text('Proceed to Pay'),
          ),
        ],
      ),
    );
  }
}

// (This class should be in your main.dart file)


class PaymentPage extends StatefulWidget {
  final Map<String, dynamic> bookingDetails;

  PaymentPage({required this.bookingDetails});

  @override
  _PaymentPageState createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  final _formKey = GlobalKey<FormState>();
  bool _isPaying = false;

  Future<void> _processPayment() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isPaying = true);

    // Simulate payment API call
    await Future.delayed(Duration(seconds: 3));

    // After successful payment, save all data to Firestore
    await _saveBookingData();

    if (mounted) {
      setState(() => _isPaying = false);
    }
    
    // Show confirmation dialog
    _showBookingConfirmation();
  }

  // --- THIS IS THE CORE CHANGE: Saving all data to Firestore ---
  // (In your PaymentPage class)

  Future<void> _saveBookingData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: You are not logged in.")),
      );
      return;
    }

    try {
      final batch = FirebaseFirestore.instance.batch();

      // --- Operation 1: Create the new ticket document ---
      final ticketRef = FirebaseFirestore.instance.collection('tickets').doc();
      batch.set(ticketRef, {
        ...widget.bookingDetails,
        'userId': user.uid,
        'bookedAt': Timestamp.now(),
        'status': 'Confirmed',
      });
      
      // Create the shorter ID. The yellow line is still here for now...
      final bookingId = ticketRef.id.substring(0, 8).toUpperCase(); 


      // --- Operation 2: Create a notification for the booking ---
      final notificationRef = FirebaseFirestore.instance.collection('notifications').doc();
      batch.set(notificationRef, {
        'userId': user.uid,
        'title': 'Ticket Booked Successfully!',
        // --- THE FIX IS HERE ---
        // We now USE the bookingId variable, so the warning will disappear.
        'subtitle': 'ID: $bookingId | Route: ${widget.bookingDetails['source']} → ${widget.bookingDetails['destination']}',
        'createdAt': Timestamp.now(),
        'type': 'booking_success',
        'isRead': false,
      });

      // --- Operation 3: Update the user's reward points ---
      final userDocRef = FirebaseFirestore.instance.collection('users').doc(user.uid);
      batch.update(userDocRef, {
        'rewardPoints': FieldValue.increment(50),
      });

      // Commit all the operations
      await batch.commit();

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("An error occurred while saving your booking.")),
      );
    }
  }


  // The rest of your UI and other methods remain the same.
  void _showBookingConfirmation() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text('Booking Confirmed!'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.check_circle, color: Colors.green, size: 64),
            SizedBox(height: 16),
            Text('Your ticket has been booked successfully!'),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              // Pop all screens until the root, then push to tickets page
              Navigator.of(context).popUntil((route) => route.isFirst);
              Navigator.pushNamed(context, '/tickets');
            },
            child: Text('View My Tickets'),
          ),
        ],
      ),
    );
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Complete Payment')),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Text('Order Summary', style: Theme.of(context).textTheme.titleLarge),
                      SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('${widget.bookingDetails['name']} (x${widget.bookingDetails['passengerCount']})'),
                          Text('₹${widget.bookingDetails['totalFare']}'),
                        ],
                      ),
                      Divider(height: 24),
                      Text('Total Payable: ₹${widget.bookingDetails['totalFare']}', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 24),
              TextFormField(
                decoration: InputDecoration(labelText: 'Card Number', prefixIcon: Icon(Icons.credit_card)),
                keyboardType: TextInputType.number,
                validator: (v) => v!.isEmpty ? 'Please enter card number' : null,
              ),
              SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      decoration: InputDecoration(labelText: 'Expiry Date (MM/YY)'),
                      keyboardType: TextInputType.datetime,
                       validator: (v) => v!.isEmpty ? 'Required' : null,
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      decoration: InputDecoration(labelText: 'CVV'),
                      keyboardType: TextInputType.number,
                       validator: (v) => v!.isEmpty ? 'Required' : null,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 32),
              _isPaying
                  ? Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                      onPressed: _processPayment,
                      child: Text('Pay ₹${widget.bookingDetails['totalFare']}'),
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 16),
                        textStyle: TextStyle(fontSize: 18),
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}


class LiveTrackingPage extends StatefulWidget {
  @override
  _LiveTrackingPageState createState() => _LiveTrackingPageState();
}

class _LiveTrackingPageState extends State<LiveTrackingPage> {
  String _selectedBus = 'KL45AB1234';
  Map<String, dynamic> _trackingData = {
    'currentLocation': 'Ernakulam',
    'nextStop': 'Alappuzha',
    'eta': '2:30 PM',
    'delay': '5 mins',
    'speed': '62 km/h',
    'progress': 0.4,
  };

  // Dummy data for simulation
  final List<String> _busStops = ['Ernakulam', 'Alappuzha', 'Kollam', 'Trivandrum'];
  int _currentStopIndex = 0;


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text('Live Bus Tracking'),
        backgroundColor: Colors.blue.shade800,
        elevation: 4,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildBusSelector(),
            const SizedBox(height: 20),
            _buildMapView(), // The new dummy map
            const SizedBox(height: 20),
            _buildTrackingDetails(),
            const SizedBox(height: 20),
            _buildActionButtons(),
          ],
        ),
      ),
    );
  }

  /// Card for selecting the bus
  Widget _buildBusSelector() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Tracking Bus:', style: TextStyle(color: Colors.grey.shade600)),
            DropdownButton<String>(
              value: _selectedBus,
              isExpanded: true,
              underline: SizedBox(), // Removes the underline
              icon: Icon(Icons.arrow_drop_down_circle, color: Colors.blue.shade700),
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87
              ),
              onChanged: (value) {
                if (value != null) {
                  setState(() => _selectedBus = value);
                  // You can add logic here to fetch data for the new bus
                }
              },
              items: ['KL45AB1234', 'KL67CD5678', 'KL89EF9012']
                  .map((bus) => DropdownMenuItem(value: bus, child: Text(bus)))
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }

  /// The interactive dummy map view
  Widget _buildMapView() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      clipBehavior: Clip.antiAlias, // Clips the child to the rounded corners
      child: AspectRatio(
        aspectRatio: 16 / 9,
        child: LayoutBuilder(
          builder: (context, constraints) {
            // Calculate the bus position based on progress
            final busPosition = constraints.maxWidth * _trackingData['progress'] - 20;

            return Stack(
              children: [
                // Background map image
                Image.network(
                  'https://media.wired.com/photos/59269cd37034dc5f91bec0f1/master/w_2560%2Cc_limit/GoogleMapTA.jpg',
                  width: double.infinity,
                  height: double.infinity,
                  fit: BoxFit.cover,
                ),
                // Dark overlay for better text/icon visibility
                Container(color: Colors.black.withOpacity(0.2)),

                // Start and End points
                Align(
                  alignment: Alignment.centerLeft,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 16.0),
                    child: Icon(Icons.location_pin, color: Colors.green, size: 40),
                  ),
                ),
                 Align(
                  alignment: Alignment.centerRight,
                  child: Padding(
                    padding: const EdgeInsets.only(right: 16.0),
                    child: Icon(Icons.flag, color: Colors.red, size: 40),
                  ),
                ),

                // The bus icon that moves
                AnimatedPositioned(
                  duration: Duration(milliseconds: 500),
                  left: busPosition.clamp(0.0, constraints.maxWidth - 40.0), // Clamp to stay within bounds
                  top: constraints.maxHeight / 2 - 20,
                  child: Icon(Icons.directions_bus_filled, color: Colors.yellow, size: 40),
                ),

                // Dotted line for the route path
                Positioned.fill(
                  child: Align(
                    alignment: Alignment.center,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 40.0),
                      child: Text(
                        '----------------------------------',
                        maxLines: 1,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.8),
                          fontWeight: FontWeight.bold,
                          fontSize: 24,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            );
          }
        ),
      ),
    );
  }


  /// Card displaying all tracking details
  Widget _buildTrackingDetails() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Journey Progress',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            LinearProgressIndicator(
              value: _trackingData['progress'],
              backgroundColor: Colors.grey[300],
              valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
              minHeight: 8,
            ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                '${(_trackingData['progress'] * 100).toInt()}% Complete',
                style: TextStyle(color: Colors.grey.shade600),
              ),
            ),
            const Divider(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildInfoTile(Icons.location_on, 'Next Stop', _trackingData['nextStop']),
                _buildInfoTile(Icons.access_time_filled, 'ETA', _trackingData['eta']),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildInfoTile(Icons.speed, 'Speed', _trackingData['speed']),
                _buildInfoTile(Icons.warning, 'Delay', _trackingData['delay'], valueColor: Colors.red.shade700),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// A reusable widget for displaying a piece of information
  Widget _buildInfoTile(IconData icon, String label, String value, {Color valueColor = Colors.black87}) {
    return Expanded(
      child: Row(
        children: [
          Icon(icon, color: Colors.blue.shade700, size: 28),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: TextStyle(color: Colors.grey.shade600)),
              Text(
                value,
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: valueColor),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Row of action buttons
  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: _refreshTracking,
            icon: Icon(Icons.refresh),
            label: Text('Refresh'),
            style: ElevatedButton.styleFrom(
              padding: EdgeInsets.symmetric(vertical: 12),
              backgroundColor: Colors.blue.shade700,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: _enableNotifications,
            icon: Icon(Icons.notifications_active),
            label: Text('Notify Me'),
            style: ElevatedButton.styleFrom(
              padding: EdgeInsets.symmetric(vertical: 12),
              backgroundColor: Colors.orange.shade700,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
          ),
        ),
      ],
    );
  }

  /// Simulates refreshing tracking data
  void _refreshTracking() {
    setState(() {
      // Simulate progress
      _trackingData['progress'] = (_trackingData['progress'] + 0.15).clamp(0.0, 1.0);
      
      // Simulate moving to next stop
      if (_trackingData['progress'] > 0.5 && _currentStopIndex < _busStops.length - 2) {
        _currentStopIndex++;
      }
      _trackingData['nextStop'] = _busStops[_currentStopIndex + 1];

      // Simulate random speed and delay
      _trackingData['speed'] = '${Random().nextInt(20) + 55} km/h';
      _trackingData['delay'] = '${Random().nextInt(10) + 2} mins';

    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Tracking data refreshed!'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _enableNotifications() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: Text('Enable Notifications?'),
        content: Text('You will be notified 10 minutes before the bus reaches your stop.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }
}


// The page is now a StatefulWidget to manage the loading of ticket data.
// (This class should be in your main.dart file)


class TicketsPage extends StatelessWidget { // Can be a StatelessWidget as StreamBuilder handles state

  @override
  Widget build(BuildContext context) {
    // Get the current user from Firebase Auth
    final User? currentUser = FirebaseAuth.instance.currentUser;

    // Safety check: if no user is logged in, show an appropriate message.
    if (currentUser == null) {
      return Scaffold(
        appBar: AppBar(title: Text('My Booked Tickets')),
        body: Center(
          child: Text("Please log in to view your tickets."),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text('My Booked Tickets'),
      ),
      // --- THE CORE CHANGE: Switched from FutureBuilder to StreamBuilder ---
      body: StreamBuilder<QuerySnapshot>(
        // This is the query that fetches tickets from Firestore in real-time.
        stream: FirebaseFirestore.instance
            .collection('tickets') // 1. Look in the 'tickets' collection
            .where('userId', isEqualTo: currentUser.uid) // 2. Only get tickets where the userId matches the logged-in user
            .orderBy('bookedAt', descending: true) // 3. Order them by booking date, newest first
            .snapshots(), // 4. .snapshots() creates the real-time stream
        builder: (context, snapshot) {
          
          // State 1: Still loading data from Firestore
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          // State 2: Error fetching data
          if (snapshot.hasError) {
            return Center(child: Text('Error loading tickets. Please try again.'));
          }
          
          // State 3: No tickets have been booked yet
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.airplane_ticket_outlined, size: 80, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'No tickets booked yet.',
                    style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                  ),
                  Text(
                    'Plan a new journey to see your tickets here.',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          // State 4: Data has been successfully loaded!
          final tickets = snapshot.data!.docs;
          
          return ListView.builder(
            padding: EdgeInsets.all(12),
            itemCount: tickets.length,
            itemBuilder: (context, index) {
              // Convert the Firestore DocumentSnapshot into a Map
              final ticketData = tickets[index].data() as Map<String, dynamic>;
              
              // We also pass the document ID, which is a great unique identifier
              ticketData['bookingId'] = tickets[index].id; 
              
              // Build the ticket card using the live data
              return _buildTicketCard(context, ticketData);
            },
          );
        },
      ),
    );
  }

  // --- No changes are needed to your beautiful UI widgets below this line ---

  /// Builds the visual representation of a single ticket card.
  Widget _buildTicketCard(BuildContext context, Map<String, dynamic> ticket) {
    // Generate a shorter, more readable ID for display
    final displayId = ticket['bookingId'].substring(0, 8).toUpperCase();

    return Card(
      elevation: 4,
      margin: EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: Text(
                    ticket['name'] ?? 'Bus Name',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),
                Text(
                  'ID: $displayId', // Use the generated display ID
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
              ],
            ),
            Divider(height: 24),

            _buildRouteVisualizer(ticket['source'] ?? '', ticket['destination'] ?? ''),
            SizedBox(height: 16),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildDetailItem(Icons.calendar_today, 'Date', ticket['date'] ?? 'N/A'),
                _buildDetailItem(Icons.access_time_filled, 'Departure', ticket['departure'] ?? 'N/A'),
                _buildDetailItem(Icons.people, 'Passengers', (ticket['passengerCount'] ?? 1).toString()),
              ],
            ),
            SizedBox(height: 16),
            
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  '₹${ticket['totalFare'] ?? 0}',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.green.shade700),
                ),
                ElevatedButton.icon(
                  onPressed: () => _showQRCode(context, ticket),
                  icon: Icon(Icons.qr_code_scanner, size: 20),
                  label: Text('Show QR'),
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all(Theme.of(context).primaryColor),
                    foregroundColor: MaterialStateProperty.all(Colors.white),
                    shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                      RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// A helper widget to display the route with icons.
  Widget _buildRouteVisualizer(String source, String destination) {
    return Row(
      children: [
        Icon(Icons.my_location, color: Colors.green, size: 20),
        SizedBox(width: 8),
        Text(source, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Text(' • • • • • ', textAlign: TextAlign.center, style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold), overflow: TextOverflow.clip, maxLines: 1),
          ),
        ),
        Icon(Icons.location_on, color: Colors.red, size: 20),
        SizedBox(width: 8),
        Text(destination, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
      ],
    );
  }

  /// A reusable widget for displaying small details with an icon.
  Widget _buildDetailItem(IconData icon, String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(color: Colors.grey, fontSize: 12)),
        SizedBox(height: 2),
        Row(
          children: [
            Icon(icon, size: 16, color: Colors.grey.shade700),
            SizedBox(width: 6),
            Text(value, style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
      ],
    );
  }

  /// Shows the QR code dialog.
  void _showQRCode(BuildContext context, Map<String, dynamic> ticket) {
     final displayId = (ticket['bookingId'] as String).substring(0, 8).toUpperCase();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: Center(child: Text('Your Digital Ticket')),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.qr_code_2, size: 180, color: Colors.black),
            SizedBox(height: 16),
            Text('Booking ID: $displayId', style: TextStyle(fontWeight: FontWeight.bold)),
            Text('${ticket['source']} → ${ticket['destination']}'),
            SizedBox(height: 8),
            Text('Scan this code upon boarding', style: TextStyle(fontSize: 12, color: Colors.grey)),
          ],
        ),
        actions: [
          Center(
            child: TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Close'),
            ),
          ),
        ],
      ),
    );
  }
}


// (This class should be in your main.dart file)


class SafetyPage extends StatefulWidget {
  @override
  _SafetyPageState createState() => _SafetyPageState();
}

class _SafetyPageState extends State<SafetyPage> {
  bool _voiceSosEnabled = false;
  bool _isPressingSOS = false;

  // --- THIS IS THE CORE CHANGE: Activating a real SOS alert ---
  Future<void> _activateSOS() async {
    HapticFeedback.heavyImpact();
    
    // Stop the button animation
    if (mounted) setState(() => _isPressingSOS = false);

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    // Show a "Sending..." dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text('Activating SOS...'),
        content: Center(child: CircularProgressIndicator()),
      ),
    );

    try {
      // 1. Fetch user data to get their name and emergency contacts
      final userDoc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      final userData = userDoc.data();
      final userName = userData?['name'] ?? 'A user';
      final contacts = List<Map<String, dynamic>>.from(userData?['emergencyContacts'] ?? []);
      
      String contactSummary = contacts.isNotEmpty
          ? contacts.map((c) => '• ${c['name']}').join('\n')
          : '• No contacts saved';

      // 2. Create a new "SOS Alert" notification in Firestore
      final batch = FirebaseFirestore.instance.batch();
      final notificationRef = FirebaseFirestore.instance.collection('notifications').doc();
      batch.set(notificationRef, {
        'userId': user.uid,
        'title': '🚨 SOS ALERT ACTIVATED 🚨',
        'subtitle': '$userName has activated an emergency SOS. Please contact them immediately.',
        'createdAt': Timestamp.now(),
        'type': 'sos_alert', // A new type for special styling
        'isRead': false,
      });

      // (In a real app, here you would also trigger an API call to a service like Twilio to send SMS)

      await batch.commit();
      
      // Close the "Sending..." dialog
      Navigator.pop(context);

      // 3. Show the final confirmation dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          title: Row(children: [Icon(Icons.warning, color: Colors.red), SizedBox(width: 8), Text('SOS ACTIVATED')]),
          content: Text('An emergency alert has been sent to:\n$contactSummary\n• Sanchari Control Room'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Emergency services have been notified'), backgroundColor: Colors.red),
                );
              },
              child: Text('OK'),
            ),
          ],
        ),
      );

    } catch (e) {
      // Close the "Sending..." dialog
      Navigator.pop(context);
      // Show an error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to send SOS. Check connection.'), backgroundColor: Colors.red),
      );
    }
  }
  

  // --- No changes are needed to your beautiful UI widgets below this line ---

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text('Safety & Emergency'),
        backgroundColor: Colors.red.shade700,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildSOSCard(),
            const SizedBox(height: 20),
            _buildFeaturesCard(),
            const SizedBox(height: 20),
            _buildSafetyTipsCard(),
          ],
        ),
      ),
    );
  }

  Widget _buildSOSCard() {
    return Card(
      elevation: 4,
      color: Colors.red[50],
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Text('Emergency SOS', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(
              'Press and hold the button for 3 seconds to send an alert to your emergency contacts and our control room.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[700]),
            ),
            const SizedBox(height: 24),
            GestureDetector(
              onLongPressStart: (_) => setState(() => _isPressingSOS = true),
              onLongPressEnd: (_) => setState(() => _isPressingSOS = false),
              onLongPress: _activateSOS,
              child: TweenAnimationBuilder(
                tween: Tween<double>(begin: 1.0, end: _isPressingSOS ? 1.2 : 1.0),
                duration: const Duration(milliseconds: 200),
                builder: (context, scale, child) => Transform.scale(scale: scale, child: child),
                child: Container(
                  width: 130,
                  height: 130,
                  decoration: BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                    boxShadow: [BoxShadow(color: Colors.red.withOpacity(0.4), blurRadius: 15, spreadRadius: 5)],
                  ),
                  child: Center(
                    child: _isPressingSOS
                      ? TweenAnimationBuilder(
                          tween: Tween<double>(begin: 0, end: 1),
                          duration: const Duration(seconds: 3),
                          builder: (context, value, child) => Stack(
                            alignment: Alignment.center,
                            children: [
                              SizedBox(width: 120, height: 120, child: CircularProgressIndicator(value: value, strokeWidth: 6, backgroundColor: Colors.white.withOpacity(0.3), valueColor: AlwaysStoppedAnimation<Color>(Colors.white))),
                              Text('SOS', style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold)),
                            ],
                          ),
                        )
                      : Text('SOS', style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold)),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeaturesCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Column(
        children: [
          ListTile(
            leading: Icon(Icons.contacts_rounded, color: Colors.blue.shade700),
            title: Text('Emergency Contacts'),
            subtitle: Text('Manage your trusted contacts'),
            trailing: Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () => Navigator.pushNamed(context, '/emergency_contacts'),
          ),
          Divider(height: 1),
          SwitchListTile(
            secondary: Icon(Icons.mic, color: Colors.purple.shade400),
            title: Text('Voice Command SOS'),
            subtitle: Text('Activate by saying "Help me"'),
            value: _voiceSosEnabled,
            onChanged: (value) => setState(() => _voiceSosEnabled = value),
          ),
        ],
      ),
    );
  }

  Widget _buildSafetyTipsCard() {
    return Card(
       elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Travel Safety Tips', style: Theme.of(context).textTheme.titleLarge!),
            const SizedBox(height: 12),
            _buildSafetyTip('🚌', 'Always sit near the driver or conductor if possible.'),
            _buildSafetyTip('📱', 'Keep your phone charged and readily accessible.'),
            _buildSafetyTip('👥', 'Share your journey details with family or friends.'),
            _buildSafetyTip('🚨', 'Trust your instincts. If something feels wrong, it probably is.'),
          ],
        ),
      ),
    );
  }

  Widget _buildSafetyTip(String emoji, String tip) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(emoji, style: TextStyle(fontSize: 20)),
          const SizedBox(width: 12),
          Expanded(child: Text(tip, style: TextStyle(height: 1.4))),
        ],
      ),
    );
  }
}


// (This class should be in your main.dart file)

class EmergencyContactsPage extends StatefulWidget {
  @override
  _EmergencyContactsPageState createState() => _EmergencyContactsPageState();
}

class _EmergencyContactsPageState extends State<EmergencyContactsPage> {

  // A helper function to get the reference to the user's profile document
  DocumentReference _getUserDocRef() {
    final user = FirebaseAuth.instance.currentUser!;
    return FirebaseFirestore.instance.collection('users').doc(user.uid);
  }

  // Show a dialog to add or edit a contact
  void _showAddContactDialog({Map<String, dynamic>? contact, int? index}) {
    final formKey = GlobalKey<FormState>();
    final nameController = TextEditingController(text: contact?['name']);
    final phoneController = TextEditingController(text: contact?['phone']);
    final isEditing = contact != null;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(isEditing ? 'Edit Contact' : 'Add New Contact'),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: nameController,
                  decoration: InputDecoration(labelText: 'Name'),
                  validator: (v) => v!.isEmpty ? 'Name is required' : null,
                ),
                TextFormField(
                  controller: phoneController,
                  decoration: InputDecoration(labelText: 'Phone Number'),
                  keyboardType: TextInputType.phone,
                  validator: (v) => v!.isEmpty ? 'Phone number is required' : null,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: Text('Cancel')),
            ElevatedButton(
              onPressed: () async {
                if (formKey.currentState!.validate()) {
                  final newContact = {'name': nameController.text, 'phone': phoneController.text};
                  
                  // Use Firestore's ArrayUnion to add a new contact
                  // or update an existing one.
                  if (isEditing) {
                    // To edit, we remove the old one and add the new one.
                    await _getUserDocRef().update({
                      'emergencyContacts': FieldValue.arrayRemove([contact])
                    });
                  }
                  await _getUserDocRef().update({
                    'emergencyContacts': FieldValue.arrayUnion([newContact])
                  });

                  Navigator.pop(context);
                }
              },
              child: Text('Save'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Emergency Contacts'),
      ),
      // Use a StreamBuilder to display the contacts in real-time
      body: StreamBuilder<DocumentSnapshot>(
        stream: _getUserDocRef().snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return Center(child: CircularProgressIndicator());
          
          final userData = snapshot.data!.data() as Map<String, dynamic>?;
          final List<dynamic> contacts = userData?['emergencyContacts'] ?? [];

          if (contacts.isEmpty) {
            return Center(child: Text('No contacts added yet.'));
          }

          return ListView.builder(
            itemCount: contacts.length,
            itemBuilder: (context, index) {
              final contact = contacts[index] as Map<String, dynamic>;
              return ListTile(
                leading: CircleAvatar(child: Icon(Icons.person)),
                title: Text(contact['name']!),
                subtitle: Text(contact['phone']!),
                trailing: IconButton(
                  icon: Icon(Icons.delete_outline, color: Colors.red),
                  onPressed: () {
                    // Use ArrayRemove to delete a contact
                    _getUserDocRef().update({
                      'emergencyContacts': FieldValue.arrayRemove([contact])
                    });
                  },
                ),
                onTap: () => _showAddContactDialog(contact: contact, index: index),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddContactDialog,
        child: Icon(Icons.add),
        tooltip: 'Add Contact',
      ),
    );
  }
}



// (This class should be in your main.dart file)

class FeedbackPage extends StatefulWidget {
  @override
  _FeedbackPageState createState() => _FeedbackPageState();
}

class _FeedbackPageState extends State<FeedbackPage> {
  int _rating = 0;
  final _feedbackController = TextEditingController();
  String _selectedCategory = 'Service';
  bool _isLoading = false;

  // --- THIS IS THE CORE CHANGE: Submitting feedback to Firestore ---
  Future<void> _submitFeedback() async {
    if (_rating == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please provide a star rating before submitting.')),
      );
      return;
    }

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('You must be logged in to submit feedback.')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Use a WriteBatch to perform both operations atomically
      final batch = FirebaseFirestore.instance.batch();

      // Operation 1: Create a new document in the 'feedback' collection
      final feedbackRef = FirebaseFirestore.instance.collection('feedback').doc();
      batch.set(feedbackRef, {
        'userId': user.uid,
        'rating': _rating,
        'category': _selectedCategory,
        'comment': _feedbackController.text.trim(),
        'submittedAt': Timestamp.now(),
      });

      // Operation 2: Update the user's reward points in their 'users' document
      final userDocRef = FirebaseFirestore.instance.collection('users').doc(user.uid);
      batch.update(userDocRef, {
        'rewardPoints': FieldValue.increment(25),
      });

      // Commit both operations
      await batch.commit();

      // Show success dialog
      _showSuccessDialog();

      // Clear the form for next time
      setState(() {
        _rating = 0;
        _feedbackController.clear();
        _selectedCategory = 'Service';
      });

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to submit feedback. Please try again.'), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  // Helper method for the success dialog
  void _showSuccessDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: Text('Thank You!'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.check_circle_outline, color: Colors.green, size: 64),
            SizedBox(height: 16),
            Text('Your feedback is valuable to us.\n(+25 Eco Points awarded!)', textAlign: TextAlign.center),
          ],
        ),
        actions: [
          Center(
            child: TextButton(
              onPressed: () {
                Navigator.pop(context); // Close dialog
              },
              child: Text('Done'),
            ),
          ),
        ],
      ),
    );
  }

  // The UI remains largely the same. We just connect the button to the new logic.
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(title: Text('Support & Feedback')),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            _buildSupportCard(context), // I've used the cleaner UI from a previous step
            SizedBox(height: 20),
            _buildFeedbackCard(context),
          ],
        ),
      ),
    );
  }

  Widget _buildSupportCard(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Need Instant Help?', style: Theme.of(context).textTheme.titleLarge!),
            SizedBox(height: 8),
            Text('Chat with our AI assistant for quick solutions to your questions.', style: TextStyle(color: Colors.grey[600])),
            SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () => Navigator.pushNamed(context, '/chat'),
              icon: Icon(Icons.chat_bubble_outline),
              label: Text('Start Chat with AI Assistant'),
              style: ElevatedButton.styleFrom(padding: EdgeInsets.symmetric(vertical: 12), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeedbackCard(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Rate Your Journey', style: Theme.of(context).textTheme.titleLarge!),
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (index) => IconButton(
                onPressed: () => setState(() => _rating = index + 1),
                icon: Icon(index < _rating ? Icons.star : Icons.star_border, color: Colors.amber, size: 36),
              )),
            ),
            SizedBox(height: 20),
            DropdownButtonFormField<String>(
              value: _selectedCategory,
              decoration: InputDecoration(labelText: 'Feedback Category', border: OutlineInputBorder()),
              items: ['Service', 'Cleanliness', 'Punctuality', 'Driver Behavior', 'Other']
                  .map((cat) => DropdownMenuItem(value: cat, child: Text(cat)))
                  .toList(),
              onChanged: (value) => setState(() => _selectedCategory = value!),
            ),
            SizedBox(height: 16),
            TextField(
              controller: _feedbackController,
              maxLines: 4,
              decoration: InputDecoration(hintText: 'Tell us how we can improve...', border: OutlineInputBorder()),
            ),
            SizedBox(height: 20),
            _isLoading
                ? Center(child: CircularProgressIndicator())
                : ElevatedButton.icon(
                    onPressed: _submitFeedback,
                    icon: Icon(Icons.send_rounded),
                    label: Text('Submit Feedback'),
                    style: ElevatedButton.styleFrom(minimumSize: Size(double.infinity, 50), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                  ),
          ],
        ),
      ),
    );
  }
}


// (This class should be in your main.dart file)


class RewardsPage extends StatelessWidget { // Can be a StatelessWidget as StreamBuilders handle state

  // Function to handle taps on the "Earn Points" chips
  void _handleEarnChipTap(BuildContext context, String action) {
    switch (action) {
      case 'book':
        // Navigate to the route planner page
        Navigator.pushNamed(context, '/route-planner');
        break;
      case 'feedback':
        // Navigate to the feedback page
        Navigator.pushNamed(context, '/feedback');
        break;
      case 'share':
        // Use the share_plus package to open the native share dialog
        Share.share(
          'Check out the Sanchari Bus App! It makes booking and tracking buses so easy. Download it here: [Your App Link]',
          subject: 'Join me on Sanchari!'
        );
        break;
      default:
        // Handle other cases like 'Monthly Goal'
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('This feature is coming soon!'))
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    // Safety check if the user is not logged in
    if (user == null) {
      return Scaffold(
        appBar: AppBar(title: Text('Eco Rewards')),
        body: Center(child: Text("Please log in to see your rewards.")),
      );
    }

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(title: Text('Eco Rewards')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // The points header now uses a StreamBuilder to get live data
            StreamBuilder<DocumentSnapshot>(
              stream: FirebaseFirestore.instance.collection('users').doc(user.uid).snapshots(),
              builder: (context, userSnapshot) {
                if (userSnapshot.connectionState == ConnectionState.waiting || !userSnapshot.hasData) {
                  return Center(child: CircularProgressIndicator()); // Placeholder while loading
                }
                final userData = userSnapshot.data!.data() as Map<String, dynamic>;
                final rewardPoints = userData['rewardPoints'] ?? 0;
                
                // Pass the live points to the build method
                return _buildPointsHeader(context, rewardPoints);
              },
            ),
            SizedBox(height: 24),
            _buildEarnPointsSection(context),
            SizedBox(height: 24),
            _buildRewardsList(context),
          ],
        ),
      ),
    );
  }

  // --- UI WIDGETS ---

  Widget _buildPointsHeader(BuildContext context, int rewardPoints) {
    // Placeholder logic for progress bar, can be improved with real data
    final double progress = min(1.0, rewardPoints / 1500.0);
    final int pointsNeeded = max(0, 1500 - rewardPoints);

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Container(
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          gradient: LinearGradient(
            colors: [Colors.green.shade600, Colors.teal.shade500],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.energy_savings_leaf, color: Colors.white, size: 28),
                SizedBox(width: 8),
                Text('Your Eco Points', style: TextStyle(color: Colors.white, fontSize: 18)),
              ],
            ),
            SizedBox(height: 12),
            Text(
              '$rewardPoints',
              style: TextStyle(color: Colors.white, fontSize: 48, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.white.withOpacity(0.3),
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              minHeight: 6,
            ),
            SizedBox(height: 8),
            Text(
              pointsNeeded > 0 ? '$pointsNeeded points to your next reward!' : 'You can redeem all rewards!',
              style: TextStyle(color: Colors.white70, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEarnPointsSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('How to Earn More', style: Theme.of(context).textTheme.titleLarge!),
        SizedBox(height: 12),
        Wrap(
          spacing: 12.0,
          runSpacing: 12.0,
          children: [
            _buildEarnChip(context, Icons.airplane_ticket, 'Book a ticket', '+50 pts', 'book'),
            _buildEarnChip(context, Icons.rate_review, 'Give Feedback', '+25 pts', 'feedback'),
            _buildEarnChip(context, Icons.share, 'Share the app', '+100 pts', 'share'),
            _buildEarnChip(context, Icons.star, 'Monthly Goal', '+200 pts', 'goal'),
          ],
        ),
      ],
    );
  }

  Widget _buildEarnChip(BuildContext context, IconData icon, String label, String points, String action) {
    return InkWell(
      onTap: () => _handleEarnChipTap(context, action),
      borderRadius: BorderRadius.circular(20),
      child: Chip(
        avatar: Icon(icon, color: Colors.green.shade800, size: 20),
        label: Text('$label ($points)'),
        backgroundColor: Colors.green.withOpacity(0.1),
        labelStyle: TextStyle(color: Colors.green.shade900, fontWeight: FontWeight.w500),
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
    );
  }

  Widget _buildRewardsList(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Redeem Your Points', style: Theme.of(context).textTheme.titleLarge!),
        SizedBox(height: 12),
        // This nested StreamBuilder gets the list of rewards AND the user's current points
        StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance.collection('rewards').orderBy('points').snapshots(),
          builder: (context, rewardsSnapshot) {
            if (rewardsSnapshot.connectionState == ConnectionState.waiting) return Center(child: CircularProgressIndicator());
            if (!rewardsSnapshot.hasData || rewardsSnapshot.data!.docs.isEmpty) return Text("No rewards available right now.");
            
            return StreamBuilder<DocumentSnapshot>(
              stream: FirebaseFirestore.instance.collection('users').doc(FirebaseAuth.instance.currentUser!.uid).snapshots(),
              builder: (context, userSnapshot) {
                if (userSnapshot.connectionState == ConnectionState.waiting || !userSnapshot.hasData) return Center(child: CircularProgressIndicator());
                
                final rewardPoints = (userSnapshot.data!.data() as Map<String, dynamic>)['rewardPoints'] ?? 0;
                
                return ListView.builder(
                  itemCount: rewardsSnapshot.data!.docs.length,
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemBuilder: (context, index) {
                    final rewardDoc = rewardsSnapshot.data!.docs[index];
                    final reward = rewardDoc.data() as Map<String, dynamic>;
                    
                    return _buildRewardCard(context, reward, rewardPoints);
                  },
                );
              },
            );
          },
        ),
      ],
    );
  }

  Widget _buildRewardCard(BuildContext context, Map<String, dynamic> reward, int currentUserPoints) {
    final int requiredPoints = reward['points'] ?? 9999;
    bool canRedeem = currentUserPoints >= requiredPoints;
    
    return Card(
      margin: EdgeInsets.only(bottom: 12),
      elevation: canRedeem ? 2 : 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Opacity(
        opacity: canRedeem ? 1.0 : 0.6,
        child: ListTile(
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          leading: _buildRewardIcon(requiredPoints),
          title: Text(reward['title'] ?? 'No Title', style: TextStyle(fontWeight: FontWeight.bold)),
          subtitle: Text(reward['description'] ?? ''),
          trailing: canRedeem
              ? ElevatedButton(
                  onPressed: () => _redeemReward(context, reward, currentUserPoints),
                  child: Text('Redeem'),
                )
              : _buildLockedState(requiredPoints, currentUserPoints),
        ),
      ),
    );
  }
  
  Widget _buildRewardIcon(int points) {
    return Stack(
      alignment: Alignment.center,
      children: [
        CircleAvatar(
          radius: 28,
          backgroundColor: Colors.green.withOpacity(0.1),
          child: Icon(Icons.card_giftcard, color: Colors.green.shade700, size: 30),
        ),
        Positioned(
          bottom: 0, right: 0,
          child: CircleAvatar(
            radius: 10,
            backgroundColor: Colors.green.shade700,
            child: Icon(Icons.star, color: Colors.white, size: 12),
          ),
        ),
      ],
    );
  }
  
  Widget _buildLockedState(int requiredPoints, int currentUserPoints) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.lock, color: Colors.grey, size: 20),
        SizedBox(height: 4),
        Text(
          '${requiredPoints - currentUserPoints} more',
          style: TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  // --- LOGIC METHODS ---

  void _redeemReward(BuildContext context, Map<String, dynamic> reward, int currentUserPoints) {
    final int requiredPoints = reward['points'] ?? 9999;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: Text('Confirm Redemption'),
        content: Text('Redeem "${reward['title']}" for $requiredPoints points?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              final user = FirebaseAuth.instance.currentUser!;
              
              // Subtract the points from the user's document in Firestore
              await FirebaseFirestore.instance.collection('users').doc(user.uid).update({
                'rewardPoints': FieldValue.increment(-requiredPoints)
              });
              
              Navigator.pop(context); // Close confirmation dialog
              _showRedemptionSuccess(context, reward);
            },
            child: Text('Confirm'),
          ),
        ],
      ),
    );
  }

  // This is the complete function you asked for.
  void _showRedemptionSuccess(BuildContext context, Map<String, dynamic> reward) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: Text('Reward Redeemed!'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.check_circle, color: Colors.green, size: 64),
            SizedBox(height: 16),
            Text('You have successfully redeemed:', textAlign: TextAlign.center),
            SizedBox(height: 8),
            Text(reward['title'], style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        actions: [
          Center(
            child: TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Awesome!'),
            ),
          ),
        ],
      ),
    );
  }
}

