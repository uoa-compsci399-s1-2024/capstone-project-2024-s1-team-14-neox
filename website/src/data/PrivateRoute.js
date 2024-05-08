import { useState, useEffect } from 'react';
import { Auth, Amplify } from 'aws-amplify';
import { Navigate } from 'react-router-dom';
import DisplayChart from './displayChart'; // Import DisplayChart
import Login from './login';
import Home from './home';
const PrivateRoutes = () => {
  const [isAuthenticated, setIsAuthenticated] = useState(false);
  const [isLoading, setIsLoading] = useState(true);

  useEffect(() => {
    checkAuth();
  }, []);

  const checkAuth = async () => {
    try {
      await Auth.currentAuthenticatedUser();
      setIsAuthenticated(true);
    } catch (error) {
      setIsAuthenticated(false);
    }
    setIsLoading(false);
  };

  return isAuthenticated ? <DisplayChart/> : <Home/>;
};

export default PrivateRoutes;
