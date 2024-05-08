import React, { useState, useEffect } from 'react';
import { Auth } from 'aws-amplify';
import { Redirect } from 'react-router-dom';
import Login from './login';
import Home from './home';
import DisplayChart from './displayChart';

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

  return isAuthenticated ? <DisplayChart /> : <Home />;
};

export default PrivateRoutes;
