# C My Hub Backend

Backend server for the C My Hub health tracking application, built with TypeScript, Node.js, and Supabase.

## 🚀 Getting Started

### Prerequisites

- Node.js 18+ and npm
- Supabase account and project

### Installation

1. **Install dependencies:**

   ```sh
   npm install
   ```

2. **Set up environment variables:**

   ```sh
   cp .env.example .env
   ```

   Then edit `.env` and add your Supabase credentials:
   - `SUPABASE_URL`: Your Supabase project URL
   - `SUPABASE_ANON_KEY`: Your Supabase anonymous key
   - `SUPABASE_SERVICE_ROLE_KEY`: Your Supabase service role key (for admin operations)

3. **Run the development server:**

   ```sh
   npm run dev
   ```

   The server will start on `http://localhost:3000` (or the port specified in `.env`).

## 📁 Project Structure

```
backend/
├── src/                      # Express.js backend (legacy)
│   ├── config/
│   │   └── supabase.ts      # Supabase client configuration
│   └── index.ts              # Main server entry point
├── supabase/                 # Supabase Edge Functions (recommended)
│   ├── functions/
│   │   ├── _shared/         # Shared utilities
│   │   ├── health/          # Health check endpoint
│   │   └── health-data/     # Health data endpoints
│   └── config.toml          # Supabase configuration
├── dist/                     # Compiled JavaScript (generated)
├── .env.example              # Environment variables template
├── package.json
├── tsconfig.json
└── README.md
```

> **Note**: This project now supports both Express.js backend and Supabase Edge Functions. See [Edge Functions README](./supabase/functions/README.md) for edge functions setup. Edge Functions are recommended for production deployment.

## 🛠️ Available Scripts

- `npm run dev` - Start development server with hot reload
- `npm run dev:debug` - Start server with Node.js inspector enabled (for debugging)
- `npm run dev:debug-brk` - Start server with inspector and break on start
- `npm run build` - Build TypeScript to JavaScript
- `npm start` - Run the production build
- `npm run lint` - Run ESLint
- `npm run type-check` - Type check without emitting files

## 🐛 Debugging

### VS Code Debugging

The project includes pre-configured VS Code debug configurations:

1. **Backend Debug (Node.js + TypeScript)** - Launches the backend server with debugging enabled
   - Set breakpoints in your TypeScript files
   - Step through code, inspect variables, and evaluate expressions
   - Automatically loads environment variables from `.env` file

2. **Backend Debug (Break on Start)** - Same as above but breaks immediately on start
   - Useful for debugging initialization code

3. **Backend Debug (Attach)** - Attach to an already running backend process
   - Start the server manually with: `npm run dev:debug`
   - Then attach using this configuration

4. **Full Stack Debug (Frontend + Backend)** - Debug both Flutter frontend and Node.js backend simultaneously
   - Launches both debuggers in a compound configuration
   - Perfect for full-stack development

### Using the Debugger

1. Open VS Code in the project root
2. Press `F5` or go to Run and Debug (`Cmd+Shift+D` on Mac, `Ctrl+Shift+D` on Windows/Linux)
3. Select a debug configuration from the dropdown
4. Set breakpoints by clicking in the gutter next to line numbers
5. Start debugging!

### Manual Debugging

To debug manually, you can also run:

```sh
npm run dev:debug
```

Then attach a debugger to port `9229` (default Node.js inspector port).

## 🔌 API Endpoints

### Express.js Backend (Local Development)
- `GET /health` - Server health status
- `GET /api/health-data` - Fetch health data
- `POST /api/health-data` - Create new health data entry

### Supabase Edge Functions (Production)
- `GET /functions/v1/health` - Server health status
- `GET /functions/v1/health-data` - Fetch health data
- `POST /functions/v1/health-data` - Create new health data entry

See [Edge Functions README](./supabase/functions/README.md) for deployment and usage.

## 🗄️ Database Schema

The backend expects a Supabase database with a `health_data` table. Example schema:

```sql
CREATE TABLE health_data (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID NOT NULL,
  steps INTEGER,
  heart_rate INTEGER,
  calories INTEGER,
  sleep_hours DECIMAL(4,2),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);
```

## 🔒 Security

- Never commit `.env` files
- Use Supabase Row Level Security (RLS) policies for data access control
- Validate and sanitize all input data
- Use environment-specific keys (anon key for client, service role key for server)

## 📝 Development

This backend is designed to work with Supabase's real-time features and can be extended with:
- Authentication middleware
- Rate limiting
- Request validation
- Error handling middleware
- Logging
- Database migrations

## 🚀 Supabase Edge Functions

This project includes Supabase Edge Functions as an alternative to the Express.js server. Edge Functions provide:
- Serverless deployment (no server management)
- Automatic scaling
- Built-in authentication context
- Lower latency
- Cost-effective (pay per invocation)

**Quick Start:**
1. Install Supabase CLI: `brew install supabase/tap/supabase`
2. Link project: `supabase link --project-ref <your-ref>`
3. Serve locally: `supabase functions serve`
4. Deploy: `supabase functions deploy`

See [Edge Functions README](./supabase/functions/README.md) and [Migration Guide](../../docs/SUPABASE_EDGE_FUNCTIONS_MIGRATION.md) for details.

