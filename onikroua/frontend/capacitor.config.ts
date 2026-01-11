import { CapacitorConfig } from '@capacitor/cli';

const config: CapacitorConfig = {
  appId: 'com.onikroua.app',
  appName: 'Onikroua',
  webDir: 'dist',
  server: {
    androidScheme: 'https'
  },
  plugins: {
    SplashScreen: {
      launchShowDuration: 2000,
      launchAutoHide: true,
      backgroundColor: "#4F46E5",
      androidSplashResourceName: "splash",
      androidScaleType: "CENTER_CROP",
      showSpinner: false,
      splashFullScreen: true,
      splashImmersive: true
    },
    StatusBar: {
      style: 'dark',
      backgroundColor: '#4F46E5'
    },
    GoogleAuth: {
      scopes: ['profile', 'email'],
      serverClientId: '569943827846-9mtqlucqe3qqk0vtkukg3o4lvbg48b5q.apps.googleusercontent.com',
      forceCodeForRefreshToken: true
    }
  }
};

export default config;
