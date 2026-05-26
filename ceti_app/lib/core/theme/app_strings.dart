/// Centralized string constants for CETI — Español (El Salvador 🇸🇻)
///
/// Structured as static maps per screen for easy future migration
/// to flutter_localizations / ARB files.
class S {
  S._();

  // ── App-wide ─────────────────────────────────────────────────────────────
  static const appName = 'CETI';
  static const appTagline = 'Gestión inteligente para tu negocio';
  static const appVersion = 'v1.0.0 · CETI SuperApp';

  // ── Splash ───────────────────────────────────────────────────────────────
  static const splashLoading = 'Cargando...';

  // ── Auth / Login ─────────────────────────────────────────────────────────
  static const loginTitle = 'Bienvenido';
  static const loginSubtitle = 'Inicia sesión para gestionar tu negocio';
  static const loginEmail = 'Correo electrónico';
  static const loginPassword = 'Contraseña';
  static const loginButton = 'Iniciar Sesión';
  static const loginForgot = '¿Olvidaste tu contraseña?';
  static const loginRemember = 'Recordarme';
  static const loginBiometric = 'Ingresar con biometría';
  static const loginNoAccount = '¿Aún no tienes cuenta?';
  static const loginRegister = 'Regístrate';
  static const loginContactAdvisor = 'Contactar Asesor';
  static const loginContactSupport = 'Soporte Técnico';
  static const loginSocialHeader = 'O continúa con';

  // ── Validation ───────────────────────────────────────────────────────────
  static const validationEmailRequired = 'El correo es obligatorio';
  static const validationEmailInvalid = 'Correo electrónico no válido';
  static const validationPasswordRequired = 'La contraseña es obligatoria';
  static const validationPasswordShort = 'Mínimo 6 caracteres';

  // ── PIN ──────────────────────────────────────────────────────────────────
  static const pinTitle = 'Ingresa tu PIN';
  static const pinSubtitle = 'Introduce tu PIN de seguridad';
  static const pinForgot = '¿Olvidaste tu PIN?';
  static const pinBiometric = 'Usar biometría';
  static const pinError = 'PIN incorrecto';
  static const pinSetup = 'Configura tu PIN de seguridad';
  static const pinSetupSubtitle = 'Crea un PIN de 4 a 6 dígitos';
  static const pinConfirm = 'Confirma tu PIN';

  // ── Navigation ───────────────────────────────────────────────────────────
  static const navHome = 'Inicio';
  static const navOrders = 'Pedidos';
  static const navInventory = 'Inventario';
  static const navLoyalty = 'Lealtad';
  static const navInbox = 'Mensajes';

  // ── Dashboard ────────────────────────────────────────────────────────────
  static const dashSalesToday = 'Ventas de Hoy';
  static const dashOrders = 'Pedidos';
  static const dashAvgTicket = 'Ticket Prom.';
  static const dashAlerts = 'Alertas';
  static const dashRecentMessages = 'Últimos Mensajes';
  static const dashRecentActivity = 'Actividad Reciente';
  static const dashReminders = 'Recordatorios';
  static const dashNoSalesPulse = '¿Registraste tu primera venta?';

  // ── POS / Orders ─────────────────────────────────────────────────────────
  static const posNewOrder = 'Nuevo Pedido';
  static const posTakeout = 'Para Llevar';
  static const posDineIn = 'Mesa';
  static const posDelivery = 'Delivery';
  static const posCheckout = 'Confirmar Pago';
  static const posCash = 'Efectivo';
  static const posTransfer = 'Transfer';
  static const posSplit = 'Dividir';

  // ── Inventory ────────────────────────────────────────────────────────────
  static const invTitle = 'Escandallo';
  static const invCostEngine = 'Motor de Costos';
  static const invProducts = 'Productos';
  static const invTopSales = 'Top Ventas';
  static const invAddProduct = '+ Producto';

  // ── Inbox ────────────────────────────────────────────────────────────────
  static const inboxTitle = 'Bandeja Omnicanal';
  static const inboxAiActive = 'IA Activa';
  static const inboxConvertOrder = 'Convertir a Pedido';

  // ── Loyalty ──────────────────────────────────────────────────────────────
  static const loyaltyTitle = 'Club Jaguar';
  static const loyaltyNfcTap = 'Toca para escanear';
  static const loyaltyBronze = 'Bronce';
  static const loyaltySilver = 'Plata';
  static const loyaltyGold = 'Oro';
  static const loyaltyTopCustomers = 'Mejores Clientes';
  static const loyaltyAppleWallet = 'Apple Wallet';
  static const loyaltyGooglePay = 'Google Pay';

  // ── Language ─────────────────────────────────────────────────────────────
  static const langSpanish = 'Español';
  static const langEnglish = 'English';
  static const langSelect = 'Idioma';
}
