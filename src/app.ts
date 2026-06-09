// Bring in Express — the tool that lets us build a web server
import express from 'express';
import trapRouter from "./routes/trap";

// Create the server (think of this like turning on the machine)
const app = express();

// Pick a port — like a door number the server listens at.
// If the system already picked one (PORT), use that. If not, use 3000.
const PORT = process.env.PORT || 3000;

// Tell the server to understand JSON — so when someone sends data, we can read it
app.use(express.json());

//all /api/* requests go to trap routes
app.use('/api', trapRouter)

// When someone visits /health, send back { status: 'ok' }
// This is just a way to check "is the server alive?"
app.get('/health', (request, response) => {
    response.json({ status: 'ok' });
});

// Start the server and begin listening for visitors on the chosen port
app.listen(PORT, () => {
    console.log(`Honeytoken trap server running on port ${PORT}`);
});

// Make this server available to other files in the project that need it
export default app;