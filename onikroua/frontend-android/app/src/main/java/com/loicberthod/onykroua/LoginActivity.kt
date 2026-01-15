package com.loicberthod.onykroua

import android.content.Intent
import android.os.Bundle
import android.widget.Button
import android.widget.EditText
import android.widget.Toast
import androidx.appcompat.app.AppCompatActivity
import com.google.android.gms.auth.api.signin.GoogleSignIn
import com.google.android.gms.auth.api.signin.GoogleSignInClient
import com.google.android.gms.auth.api.signin.GoogleSignInOptions
import com.google.android.gms.common.api.ApiException
import com.google.firebase.auth.FirebaseAuth
import com.google.firebase.auth.GoogleAuthProvider

class LoginActivity : AppCompatActivity() {
    
    private lateinit var auth: FirebaseAuth
    private lateinit var googleSignInClient: GoogleSignInClient
    
    companion object {
        private const val RC_SIGN_IN = 9001
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        
        auth = FirebaseAuth.getInstance()
        
        if (auth.currentUser != null) {
            goToMain()
            return
        }
        
        setContentView(R.layout.activity_login)
        
        val gso = GoogleSignInOptions.Builder(GoogleSignInOptions.DEFAULT_SIGN_IN)
            .requestIdToken(getString(R.string.default_web_client_id))
            .requestEmail()
            .build()
        googleSignInClient = GoogleSignIn.getClient(this, gso)
        
        val emailInput: EditText = findViewById(R.id.emailInput)
        val passwordInput: EditText = findViewById(R.id.passwordInput)
        val loginButton: Button = findViewById(R.id.loginButton)
        val registerButton: Button = findViewById(R.id.registerButton)
        val googleButton: Button = findViewById(R.id.googleButton)
        
        loginButton.setOnClickListener {
            val email = emailInput.text.toString()
            val password = passwordInput.text.toString()
            
            if (email.isNotEmpty() && password.isNotEmpty()) {
                auth.signInWithEmailAndPassword(email, password)
                    .addOnSuccessListener { goToMain() }
                    .addOnFailureListener { 
                        Toast.makeText(this, "Erreur: ${it.message}", Toast.LENGTH_SHORT).show()
                    }
            }
        }
        
        registerButton.setOnClickListener {
            val email = emailInput.text.toString()
            val password = passwordInput.text.toString()
            
            if (email.isNotEmpty() && password.isNotEmpty()) {
                auth.createUserWithEmailAndPassword(email, password)
                    .addOnSuccessListener { goToMain() }
                    .addOnFailureListener { 
                        Toast.makeText(this, "Erreur: ${it.message}", Toast.LENGTH_SHORT).show()
                    }
            }
        }
        
        googleButton.setOnClickListener {
            val signInIntent = googleSignInClient.signInIntent
            startActivityForResult(signInIntent, RC_SIGN_IN)
        }
    }
    
    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data)
        
        if (requestCode == RC_SIGN_IN) {
            val task = GoogleSignIn.getSignedInAccountFromIntent(data)
            try {
                val account = task.getResult(ApiException::class.java)
                val credential = GoogleAuthProvider.getCredential(account.idToken, null)
                auth.signInWithCredential(credential)
                    .addOnSuccessListener { goToMain() }
                    .addOnFailureListener { 
                        Toast.makeText(this, "Erreur Google", Toast.LENGTH_SHORT).show()
                    }
            } catch (e: ApiException) {
                Toast.makeText(this, "Erreur: ${e.message}", Toast.LENGTH_SHORT).show()
            }
        }
    }
    
    private fun goToMain() {
        startActivity(Intent(this, MainActivity::class.java))
        finish()
    }
}
