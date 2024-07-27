import React from "react";
import LoggedOut from "./LoggedOut";
import { useAuth, AuthProvider } from "./use-auth-client";
import "./assets/main.css";
import LoggedIn from "./LoggedIn";

function App() {
  const { isAuthenticated, identity } = useAuth();
  return (
    <>
      <header id="header">
        <section id="status" className="toast hidden">
          <span id="content"></span>
          <button className="close-button" type="button">
            <svg
              aria-hidden="true"
              className="w-5 h-5"
              fill="currentColor"
              viewBox="0 0 20 20"
              xmlns="http://www.w3.org/2000/svg"
            >
              <path
                fillRule="evenodd"
                d="M4.293 4.293a1 1 0 011.414 0L10 8.586l4.293-4.293a1 1 0 111.414 1.414L11.414 10l4.293 4.293a1 1 0 01-1.414 1.414L10 11.414l-4.293 4.293a1 1 0 01-1.414-1.414L8.586 10 4.293 5.707a1 1 0 010-1.414z"
                clipRule="evenodd"
              ></path>
            </svg>
          </button>
        </section>
      </header>
      <main id="pageContent">
        {/* <h1>V 1.0.2</h1>
        <div id="title">
          <div>env:</div>
          <ul>DFX_URL:{process.env.DFX_URL}</ul>
          <ul>DFX_BACKEND_ID:{process.env.DFX_BACKEND_ID}</ul>
          <ul>DFX_SHOW_TUTO:{process.env.DFX_SHOW_TUTO}</ul>
          <ul>DFX_MORE_VFT:{process.env.DFX_MORE_VFT}</ul>
          <ul>DFX_NETWORK:{process.env.DFX_NETWORK}</ul>
        </div> */}
        
        {isAuthenticated ? <LoggedIn /> : <LoggedOut />}
      </main>
    </>
  );
}

export default () => (
  <AuthProvider>
    <App />
  </AuthProvider>
);