import React, { useState, useEffect } from 'react';
import axios from 'axios';
import './App.css';

const API_URL = process.env.REACT_APP_API_URL || 'http://localhost:5000';

function App() {
  const [users, setUsers] = useState([]);
  const [name, setName] = useState('');
  const [email, setEmail] = useState('');
  const [loading, setLoading] = useState(false);
  const [message, setMessage] = useState('');
  const [health, setHealth] = useState(null);

  useEffect(() => {
    fetchUsers();
    checkHealth();
  }, []);

  const checkHealth = async () => {
    try {
      const res = await axios.get(`${API_URL}/health`);
      setHealth(res.data);
    } catch (err) {
      setHealth({ status: 'error', message: 'Backend not reachable' });
    }
  };

  const fetchUsers = async () => {
    try {
      const res = await axios.get(`${API_URL}/api/users`);
      setUsers(res.data);
    } catch (err) {
      console.error('Error fetching users:', err);
    }
  };

  const addUser = async (e) => {
    e.preventDefault();
    if (!name || !email) return;
    setLoading(true);
    try {
      await axios.post(`${API_URL}/api/users`, { name, email });
      setName('');
      setEmail('');
      setMessage('✅ User added successfully!');
      fetchUsers();
      setTimeout(() => setMessage(''), 3000);
    } catch (err) {
      setMessage('❌ Failed to add user.');
    }
    setLoading(false);
  };

  const deleteUser = async (id) => {
    try {
      await axios.delete(`${API_URL}/api/users/${id}`);
      fetchUsers();
    } catch (err) {
      console.error('Error deleting user:', err);
    }
  };

  return (
    <div className="app">
      <header className="header">
        <div className="header-content">
          <div className="logo">
            <span className="logo-icon">🚀</span>
            <span className="logo-text">Simple<span className="logo-accent">Project</span></span>
          </div>
          <div className={`status-badge ${health?.status === 'ok' ? 'online' : 'offline'}`}>
            <span className="status-dot"></span>
            {health?.status === 'ok' ? 'Backend Online' : 'Backend Offline'}
          </div>
        </div>
      </header>

      <main className="main">
        <div className="hero">
          <h1>AWS Full-Stack Demo</h1>
          <p>Deployed via <strong>CodeCommit → CodeBuild → ECR → CodeDeploy</strong></p>
        </div>

        <div className="grid">
          <div className="card">
            <h2>➕ Add User</h2>
            <form onSubmit={addUser} className="form">
              <div className="field">
                <label>Name</label>
                <input
                  type="text"
                  placeholder="Enter full name"
                  value={name}
                  onChange={(e) => setName(e.target.value)}
                  required
                />
              </div>
              <div className="field">
                <label>Email</label>
                <input
                  type="email"
                  placeholder="Enter email address"
                  value={email}
                  onChange={(e) => setEmail(e.target.value)}
                  required
                />
              </div>
              {message && <div className="message">{message}</div>}
              <button type="submit" disabled={loading} className="btn-primary">
                {loading ? 'Adding...' : 'Add User'}
              </button>
            </form>
          </div>

          <div className="card">
            <h2>👥 Users ({users.length})</h2>
            {users.length === 0 ? (
              <div className="empty-state">
                <span>📭</span>
                <p>No users yet. Add one!</p>
              </div>
            ) : (
              <ul className="user-list">
                {users.map((user) => (
                  <li key={user.id} className="user-item">
                    <div className="user-avatar">{user.name[0].toUpperCase()}</div>
                    <div className="user-info">
                      <strong>{user.name}</strong>
                      <span>{user.email}</span>
                    </div>
                    <button onClick={() => deleteUser(user.id)} className="btn-danger">×</button>
                  </li>
                ))}
              </ul>
            )}
          </div>
        </div>

        <div className="info-bar">
          <div className="info-item">
            <span className="info-label">Environment</span>
            <span className="info-value">{process.env.NODE_ENV}</span>
          </div>
          <div className="info-item">
            <span className="info-label">API URL</span>
            <span className="info-value">{API_URL}</span>
          </div>
          {health && (
            <div className="info-item">
              <span className="info-label">DB Status</span>
              <span className="info-value">{health.database || 'N/A'}</span>
            </div>
          )}
        </div>
      </main>
    </div>
  );
}

export default App;
