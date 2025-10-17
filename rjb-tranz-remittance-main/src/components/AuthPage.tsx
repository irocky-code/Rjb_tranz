import React, { useState } from 'react';
import { Button } from '@/components/ui/button';
import { Input } from '@/components/ui/input';
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '@/components/ui/card';
import { Tabs, TabsContent, TabsList, TabsTrigger } from '@/components/ui/tabs';
import { Separator } from '@/components/ui/separator';
import { Alert, AlertDescription } from '@/components/ui/alert';
import GetStartedPage from './GetStartedPage';
import { 
  Buildings, 
  TrendUp, 
  FileText, 
  Shield, 
  Eye, 
  EyeSlash,
  User,
  EnvelopeSimple,
  Lock,
  ArrowRight,
  GoogleLogo,
  FacebookLogo,
  XLogo,
  Warning,
  Sparkle
} from '@phosphor-icons/react';

interface AuthPageProps {
  onLogin: (username: string) => void;
}

interface FeatureCardProps {
  icon: React.ReactNode;
  title: string;
  description: string;
  delay: number;
}

const FeatureCard: React.FC<FeatureCardProps> = ({ icon, title, description, delay }) => (
  <div
    className="relative p-6 rounded-2xl border border-white/20 bg-white/5 backdrop-blur-xl hover:bg-white/10 hover:border-white/30 transition-all duration-300 animate-fade-in group overflow-hidden"
    style={{ animationDelay: `${delay}s` }}
  >
    {/* Glass morphism glow effect */}
    <div className="absolute inset-0 bg-gradient-to-br from-blue-500/10 to-purple-500/10 opacity-0 group-hover:opacity-100 transition-opacity duration-300 rounded-2xl"></div>
    
    <div className="flex items-start space-x-4 relative z-10">
      <div className="p-3 rounded-xl bg-gradient-to-br from-primary/30 to-blue-600/30 text-white backdrop-blur-sm border border-white/20 group-hover:scale-110 transition-transform duration-300">
        {icon}
      </div>
      <div className="flex-1">
        <h3 className="text-white font-semibold text-lg mb-2 font-montserrat group-hover:text-blue-100 transition-colors duration-300">{title}</h3>
        <p className="text-white/70 text-sm leading-relaxed font-montserrat group-hover:text-white/80 transition-colors duration-300">{description}</p>
      </div>
    </div>
  </div>
);

const AuthPage: React.FC<AuthPageProps> = ({ onLogin }) => {
  const [currentPage, setCurrentPage] = useState<'welcome' | 'auth'>('welcome');
  const [authMode, setAuthMode] = useState<'signin' | 'signup'>('signin');
  const [showPassword, setShowPassword] = useState(false);
  const [showConfirmPassword, setShowConfirmPassword] = useState(false);
  const [isLoading, setIsLoading] = useState(false);
  const [errors, setErrors] = useState<string[]>([]);
  const [formData, setFormData] = useState({
    username: '',
    email: '',
    password: '',
    confirmPassword: ''
  });

  const validatePassword = (password: string): string[] => {
    const errors: string[] = [];
    if (password.length < 8) {
      errors.push('Password must be at least 8 characters long');
    }
    if (!/(?=.*[a-z])/.test(password)) {
      errors.push('Password must contain at least one lowercase letter');
    }
    if (!/(?=.*[A-Z])/.test(password)) {
      errors.push('Password must contain at least one uppercase letter');
    }
    if (!/(?=.*\d)/.test(password)) {
      errors.push('Password must contain at least one number');
    }
    if (!/(?=.*[!@#$%^&*()_+\-=\[\]{};':"\\|,.<>\/?])/.test(password)) {
      errors.push('Password must contain at least one special character');
    }
    return errors;
  };

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setErrors([]);
    setIsLoading(true);

    // Validation
    const validationErrors: string[] = [];

    if (authMode === 'signup') {
      if (!formData.username.trim()) {
        validationErrors.push('Username is required');
      }
      if (!formData.email.trim()) {
        validationErrors.push('Email is required');
      }
      if (!/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(formData.email)) {
        validationErrors.push('Please enter a valid email address');
      }
      
      const passwordErrors = validatePassword(formData.password);
      validationErrors.push(...passwordErrors);
      
      if (formData.password !== formData.confirmPassword) {
        validationErrors.push('Passwords do not match');
      }
    } else {
      if (!formData.username.trim()) {
        validationErrors.push('Username or email is required');
      }
      if (!formData.password.trim()) {
        validationErrors.push('Password is required');
      }
    }

    if (validationErrors.length > 0) {
      setErrors(validationErrors);
      setIsLoading(false);
      return;
    }

    // Simulate API call
    await new Promise(resolve => setTimeout(resolve, 1500));

    if (authMode === 'signin') {
      onLogin(formData.username || formData.email.split('@')[0]);
    } else {
      // For signup, use username if provided, otherwise email prefix
      onLogin(formData.username || formData.email.split('@')[0]);
    }

    setIsLoading(false);
  };

  const handleSocialLogin = async (provider: 'google' | 'facebook' | 'x') => {
    setIsLoading(true);
    
    // Simulate social login
    await new Promise(resolve => setTimeout(resolve, 2000));
    
    // For demo purposes, auto-login with provider name
    onLogin(`Admin via ${provider.charAt(0).toUpperCase() + provider.slice(1)}`);
    
    setIsLoading(false);
  };

  const handleInputChange = (field: string, value: string) => {
    setFormData(prev => ({ ...prev, [field]: value }));
    // Clear errors when user starts typing
    if (errors.length > 0) {
      setErrors([]);
    }
  };

  // Show the Get Started page first
  if (currentPage === 'welcome') {
    return <GetStartedPage onGetStarted={() => setCurrentPage('auth')} />;
  }

  return (
    <div className="min-h-screen auth-background flex flex-col relative overflow-hidden">
      {/* Enhanced Background with gradient overlay */}
      <div className="absolute inset-0 bg-gradient-to-br from-slate-900 via-blue-900 to-slate-800" />
      <div className="absolute inset-0 bg-gradient-to-t from-black/30 to-transparent" />
      
      {/* Animated Background Elements */}
      <div className="absolute inset-0 overflow-hidden pointer-events-none">
        <div className="absolute top-20 left-10 w-96 h-96 bg-blue-500/20 rounded-full blur-3xl animate-pulse"></div>
        <div className="absolute bottom-20 right-10 w-[500px] h-[500px] bg-purple-500/20 rounded-full blur-3xl animate-pulse" style={{animationDelay: '1s'}}></div>
        <div className="absolute top-1/2 left-1/2 transform -translate-x-1/2 -translate-y-1/2 w-80 h-80 bg-blue-400/10 rounded-full blur-2xl animate-float"></div>
      </div>
      
      {/* Content */}
      <div className="relative z-10 flex-1 flex flex-col">
        {/* Header Section */}
        <div className="flex-1 flex flex-col items-center justify-center px-4 py-8">
          {/* Logo and Brand */}
          <div className="text-center mb-12 animate-fade-in">
            {/* Enhanced 3D-style logo container with glass morphism */}
            <div className="relative mx-auto mb-8">
              <div className="w-28 h-28 md:w-36 md:h-36 mx-auto rounded-full bg-gradient-to-br from-primary via-blue-600 to-blue-800 p-1 shadow-2xl animate-logo-bounce">
                <div className="w-full h-full rounded-full bg-gradient-to-br from-blue-500 to-blue-700 flex items-center justify-center shadow-inner relative overflow-hidden backdrop-blur-sm">
                  <img 
                    src="https://i.ibb.co/6LY7bxR/rjb-logo.jpg" 
                    alt="RJB TRANZ Logo" 
                    className="w-14 h-14 md:w-18 md:h-18 rounded-full object-cover z-10 relative"
                  />
                  {/* Inner glow effect */}
                  <div className="absolute inset-0 bg-gradient-to-t from-blue-600/50 to-transparent rounded-full"></div>
                </div>
              </div>
              
              {/* Multiple glow layers */}
              <div className="absolute inset-0 w-28 h-28 md:w-36 md:h-36 mx-auto rounded-full bg-blue-500/30 blur-xl animate-pulse"></div>
              <div className="absolute inset-0 w-28 h-28 md:w-36 md:h-36 mx-auto rounded-full bg-blue-400/20 blur-2xl animate-pulse" style={{animationDelay: '0.5s'}}></div>
              
              {/* Floating sparkles */}
              <div className="absolute -top-2 -left-2 text-blue-300 animate-bounce" style={{animationDelay: '0.2s'}}>
                <Sparkle className="h-4 w-4" weight="fill" />
              </div>
              <div className="absolute -bottom-2 -right-2 text-blue-300 animate-bounce" style={{animationDelay: '0.8s'}}>
                <Sparkle className="h-4 w-4" weight="fill" />
              </div>
            </div>

            <h1 className="text-4xl md:text-5xl font-bold text-white mb-4 font-montserrat tracking-tight animate-fade-in bg-gradient-to-r from-white via-blue-100 to-white bg-clip-text text-transparent"
                style={{ animationDelay: '0.3s' }}>
              RJB TRANZ
            </h1>
            
            <p className="text-lg md:text-xl text-white/90 mb-2 font-montserrat animate-fade-in font-light"
               style={{ animationDelay: '0.5s' }}>
              Remittance Management System
            </p>
            
            <p className="text-sm md:text-base text-white/70 max-w-md mx-auto font-montserrat leading-relaxed animate-fade-in"
               style={{ animationDelay: '0.7s' }}>
              Streamline your international money transfers and transaction management
            </p>
          </div>

          {/* Enhanced Feature Cards with Glass Morphism */}
          <div className="w-full max-w-2xl mx-auto space-y-4 mb-12">
            <FeatureCard
              icon={<TrendUp className="h-6 w-6" weight="duotone" />}
              title="Real-time Exchange Rates"
              description="Live currency conversion with instant updates"
              delay={0.9}
            />
            <FeatureCard
              icon={<FileText className="h-6 w-6" weight="duotone" />}
              title="Invoice Management"
              description="Create, track and manage transaction records"
              delay={1.1}
            />
            <FeatureCard
              icon={<Shield className="h-6 w-6" weight="duotone" />}
              title="Secure Transactions"
              description="Enterprise-grade security for all operations"
              delay={1.3}
            />
          </div>

          {/* Enhanced Auth Form with Glass Morphism */}
          <div className="w-full max-w-md mx-auto animate-fade-in"
               style={{ animationDelay: '1.5s' }}>
            <Card className="relative border border-white/20 shadow-2xl overflow-hidden backdrop-blur-xl bg-white/10">
              {/* Glass morphism overlay */}
              <div className="absolute inset-0 bg-gradient-to-br from-white/10 via-white/5 to-transparent pointer-events-none"></div>
              
              <CardHeader className="text-center pb-4 relative z-10">
                <CardTitle className="text-white text-2xl font-montserrat font-bold">
                  Welcome to RJB TRANZ
                </CardTitle>
                <CardDescription className="text-white/80 font-montserrat text-base mt-2">
                  Sign in to access your admin dashboard
                </CardDescription>
              </CardHeader>
              
              <CardContent className="relative z-10">
                {errors.length > 0 && (
                  <Alert className="mb-4 bg-red-500/20 border-red-500/30 text-red-100 backdrop-blur-sm animate-fade-in">
                    <Warning className="h-4 w-4" />
                    <AlertDescription>
                      <ul className="list-disc list-inside space-y-1 text-sm">
                        {errors.map((error, index) => (
                          <li key={index}>{error}</li>
                        ))}
                      </ul>
                    </AlertDescription>
                  </Alert>
                )}

                <Tabs value={authMode} onValueChange={(value) => setAuthMode(value as 'signin' | 'signup')}>
                  <TabsList className="grid w-full grid-cols-2 mb-6 bg-white/10 backdrop-blur-md border border-white/20 p-1">
                    <TabsTrigger 
                      value="signin" 
                      className="text-white data-[state=active]:bg-gradient-to-r data-[state=active]:from-primary data-[state=active]:to-blue-600 data-[state=active]:text-white data-[state=active]:shadow-lg transition-all duration-300 font-montserrat font-medium"
                    >
                      Sign In
                    </TabsTrigger>
                    <TabsTrigger 
                      value="signup" 
                      className="text-white data-[state=active]:bg-gradient-to-r data-[state=active]:from-primary data-[state=active]:to-blue-600 data-[state=active]:text-white data-[state=active]:shadow-lg transition-all duration-300 font-montserrat font-medium"
                    >
                      Sign Up
                    </TabsTrigger>
                  </TabsList>

                  <TabsContent value="signin">
                    <form onSubmit={handleSubmit} className="space-y-4">
                      <div className="space-y-2">
                        <div className="relative group">
                          <User className="absolute left-3 top-1/2 transform -translate-y-1/2 h-5 w-5 text-white/60 group-hover:text-white/80 transition-colors duration-300" weight="duotone" />
                          <Input
                            type="text"
                            placeholder="Username or Email"
                            value={formData.username}
                            onChange={(e) => handleInputChange('username', e.target.value)}
                            className="pl-10 h-12 bg-white/10 backdrop-blur-md border-white/30 text-white placeholder:text-white/50 focus:border-blue-400 focus:bg-white/15 transition-all duration-300 hover:bg-white/15 font-montserrat"
                            required
                          />
                        </div>
                      </div>
                      
                      <div className="space-y-2">
                        <div className="relative group">
                          <Lock className="absolute left-3 top-1/2 transform -translate-y-1/2 h-5 w-5 text-white/60 group-hover:text-white/80 transition-colors duration-300" weight="duotone" />
                          <Input
                            type={showPassword ? "text" : "password"}
                            placeholder="Password"
                            value={formData.password}
                            onChange={(e) => handleInputChange('password', e.target.value)}
                            className="pl-10 pr-10 h-12 bg-white/10 backdrop-blur-md border-white/30 text-white placeholder:text-white/50 focus:border-blue-400 focus:bg-white/15 transition-all duration-300 hover:bg-white/15 font-montserrat"
                            required
                          />
                          <button
                            type="button"
                            onClick={() => setShowPassword(!showPassword)}
                            className="absolute right-3 top-1/2 transform -translate-y-1/2 text-white/60 hover:text-white/90 transition-colors duration-300"
                          >
                            {showPassword ? <EyeSlash className="h-5 w-5" weight="duotone" /> : <Eye className="h-5 w-5" weight="duotone" />}
                          </button>
                        </div>
                      </div>

                      <Button
                        type="submit"
                        className="w-full h-12 bg-gradient-to-r from-primary via-blue-600 to-blue-700 hover:from-blue-600 hover:via-blue-700 hover:to-blue-800 text-white font-semibold rounded-lg transition-all duration-300 transform hover:scale-105 hover:shadow-2xl hover:shadow-blue-500/50 group font-montserrat"
                        disabled={isLoading}
                      >
                        {isLoading ? (
                          <div className="flex items-center justify-center">
                            <div className="w-5 h-5 border-2 border-white/30 border-t-white rounded-full animate-spin mr-2" />
                            Signing In...
                          </div>
                        ) : (
                          <div className="flex items-center justify-center">
                            Get Started
                            <ArrowRight className="ml-2 h-5 w-5 group-hover:translate-x-1 transition-transform" weight="bold" />
                          </div>
                        )}
                      </Button>

                      {/* Social Login for Admins */}
                      <div className="mt-6">
                        <div className="relative">
                          <Separator className="bg-white/20" />
                          <div className="absolute inset-0 flex items-center justify-center">
                            <span className="bg-gradient-to-br from-slate-900 via-blue-900 to-slate-800 px-4 text-white/70 text-sm font-montserrat backdrop-blur-sm">
                              Admin Login Options
                            </span>
                          </div>
                        </div>
                        
                        <div className="mt-4 grid grid-cols-3 gap-3">
                          <Button
                            type="button"
                            variant="outline"
                            onClick={() => handleSocialLogin('google')}
                            disabled={isLoading}
                            className="h-12 bg-white/10 backdrop-blur-md border-white/30 text-white hover:bg-white/20 hover:border-white/40 hover:scale-110 transition-all duration-300"
                          >
                            <GoogleLogo className="h-5 w-5" weight="bold" />
                          </Button>
                          <Button
                            type="button"
                            variant="outline"
                            onClick={() => handleSocialLogin('facebook')}
                            disabled={isLoading}
                            className="h-12 bg-white/10 backdrop-blur-md border-white/30 text-white hover:bg-white/20 hover:border-white/40 hover:scale-110 transition-all duration-300"
                          >
                            <FacebookLogo className="h-5 w-5" weight="bold" />
                          </Button>
                          <Button
                            type="button"
                            variant="outline"
                            onClick={() => handleSocialLogin('x')}
                            disabled={isLoading}
                            className="h-12 bg-white/10 backdrop-blur-md border-white/30 text-white hover:bg-white/20 hover:border-white/40 hover:scale-110 transition-all duration-300"
                          >
                            <XLogo className="h-5 w-5" weight="bold" />
                          </Button>
                        </div>
                      </div>
                    </form>
                  </TabsContent>

                  <TabsContent value="signup">
                    <form onSubmit={handleSubmit} className="space-y-4">
                      <div className="space-y-2">
                        <div className="relative group">
                          <User className="absolute left-3 top-1/2 transform -translate-y-1/2 h-5 w-5 text-white/60 group-hover:text-white/80 transition-colors duration-300" weight="duotone" />
                          <Input
                            type="text"
                            placeholder="Username"
                            value={formData.username}
                            onChange={(e) => handleInputChange('username', e.target.value)}
                            className="pl-10 h-12 bg-white/10 backdrop-blur-md border-white/30 text-white placeholder:text-white/50 focus:border-blue-400 focus:bg-white/15 transition-all duration-300 hover:bg-white/15 font-montserrat"
                            required
                          />
                        </div>
                      </div>

                      <div className="space-y-2">
                        <div className="relative group">
                          <EnvelopeSimple className="absolute left-3 top-1/2 transform -translate-y-1/2 h-5 w-5 text-white/60 group-hover:text-white/80 transition-colors duration-300" weight="duotone" />
                          <Input
                            type="email"
                            placeholder="Email Address"
                            value={formData.email}
                            onChange={(e) => handleInputChange('email', e.target.value)}
                            className="pl-10 h-12 bg-white/10 backdrop-blur-md border-white/30 text-white placeholder:text-white/50 focus:border-blue-400 focus:bg-white/15 transition-all duration-300 hover:bg-white/15 font-montserrat"
                            required
                          />
                        </div>
                      </div>
                      
                      <div className="space-y-2">
                        <div className="relative group">
                          <Lock className="absolute left-3 top-1/2 transform -translate-y-1/2 h-5 w-5 text-white/60 group-hover:text-white/80 transition-colors duration-300" weight="duotone" />
                          <Input
                            type={showPassword ? "text" : "password"}
                            placeholder="Password (min 8 characters)"
                            value={formData.password}
                            onChange={(e) => handleInputChange('password', e.target.value)}
                            className="pl-10 pr-10 h-12 bg-white/10 backdrop-blur-md border-white/30 text-white placeholder:text-white/50 focus:border-blue-400 focus:bg-white/15 transition-all duration-300 hover:bg-white/15 font-montserrat"
                            required
                          />
                          <button
                            type="button"
                            onClick={() => setShowPassword(!showPassword)}
                            className="absolute right-3 top-1/2 transform -translate-y-1/2 text-white/60 hover:text-white/90 transition-colors duration-300"
                          >
                            {showPassword ? <EyeSlash className="h-5 w-5" weight="duotone" /> : <Eye className="h-5 w-5" weight="duotone" />}
                          </button>
                        </div>
                        <div className="text-xs text-white/70 pl-2 font-montserrat backdrop-blur-sm bg-white/5 p-2 rounded-lg border border-white/10">
                          Must include: uppercase, lowercase, number, special character, 8+ characters
                        </div>
                      </div>

                      <div className="space-y-2">
                        <div className="relative group">
                          <Lock className="absolute left-3 top-1/2 transform -translate-y-1/2 h-5 w-5 text-white/60 group-hover:text-white/80 transition-colors duration-300" weight="duotone" />
                          <Input
                            type={showConfirmPassword ? "text" : "password"}
                            placeholder="Confirm Password"
                            value={formData.confirmPassword}
                            onChange={(e) => handleInputChange('confirmPassword', e.target.value)}
                            className="pl-10 pr-10 h-12 bg-white/10 backdrop-blur-md border-white/30 text-white placeholder:text-white/50 focus:border-blue-400 focus:bg-white/15 transition-all duration-300 hover:bg-white/15 font-montserrat"
                            required
                          />
                          <button
                            type="button"
                            onClick={() => setShowConfirmPassword(!showConfirmPassword)}
                            className="absolute right-3 top-1/2 transform -translate-y-1/2 text-white/60 hover:text-white/90 transition-colors duration-300"
                          >
                            {showConfirmPassword ? <EyeSlash className="h-5 w-5" weight="duotone" /> : <Eye className="h-5 w-5" weight="duotone" />}
                          </button>
                        </div>
                      </div>

                      <Button
                        type="submit"
                        className="w-full h-12 bg-gradient-to-r from-primary via-blue-600 to-blue-700 hover:from-blue-600 hover:via-blue-700 hover:to-blue-800 text-white font-semibold rounded-lg transition-all duration-300 transform hover:scale-105 hover:shadow-2xl hover:shadow-blue-500/50 group font-montserrat"
                        disabled={isLoading}
                      >
                        {isLoading ? (
                          <div className="flex items-center justify-center">
                            <div className="w-5 h-5 border-2 border-white/30 border-t-white rounded-full animate-spin mr-2" />
                            Creating Account...
                          </div>
                        ) : (
                          <div className="flex items-center justify-center">
                            Create Account
                            <ArrowRight className="ml-2 h-5 w-5 group-hover:translate-x-1 transition-transform" weight="bold" />
                          </div>
                        )}
                      </Button>

                      {/* Social Login for Signup */}
                      <div className="mt-6">
                        <div className="relative">
                          <Separator className="bg-white/20" />
                          <div className="absolute inset-0 flex items-center justify-center">
                            <span className="bg-gradient-to-br from-slate-900 via-blue-900 to-slate-800 px-4 text-white/70 text-sm font-montserrat backdrop-blur-sm">
                              Sign up with
                            </span>
                          </div>
                        </div>
                        
                        <div className="mt-4 grid grid-cols-3 gap-3">
                          <Button
                            type="button"
                            variant="outline"
                            onClick={() => handleSocialLogin('google')}
                            disabled={isLoading}
                            className="h-12 bg-white/10 backdrop-blur-md border-white/30 text-white hover:bg-white/20 hover:border-white/40 hover:scale-110 transition-all duration-300"
                          >
                            <GoogleLogo className="h-5 w-5" weight="bold" />
                          </Button>
                          <Button
                            type="button"
                            variant="outline"
                            onClick={() => handleSocialLogin('facebook')}
                            disabled={isLoading}
                            className="h-12 bg-white/10 backdrop-blur-md border-white/30 text-white hover:bg-white/20 hover:border-white/40 hover:scale-110 transition-all duration-300"
                          >
                            <FacebookLogo className="h-5 w-5" weight="bold" />
                          </Button>
                          <Button
                            type="button"
                            variant="outline"
                            onClick={() => handleSocialLogin('x')}
                            disabled={isLoading}
                            className="h-12 bg-white/10 backdrop-blur-md border-white/30 text-white hover:bg-white/20 hover:border-white/40 hover:scale-110 transition-all duration-300"
                          >
                            <XLogo className="h-5 w-5" weight="bold" />
                          </Button>
                        </div>
                      </div>
                    </form>
                  </TabsContent>
                </Tabs>
              </CardContent>
            </Card>
          </div>
        </div>
        
        {/* Enhanced Footer */}
        <div className="text-center py-6 animate-fade-in relative z-10" style={{ animationDelay: '1.7s' }}>
          <p className="text-white/50 text-sm font-montserrat backdrop-blur-sm bg-white/5 inline-block px-6 py-2 rounded-full border border-white/10">
            © 2024 RJB TRANZ. All rights reserved.
          </p>
        </div>
      </div>
    </div>
  );
};

export default AuthPage;