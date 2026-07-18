export default function Home() {
  return (
    <main
      style={{
        minHeight: "100vh",
        padding: "40px",
        fontFamily: "Arial, sans-serif",
        backgroundColor: "#f1f5f9",
        color: "#1e293b",
      }}
    >
      <section
        style={{
          maxWidth: "900px",
          margin: "0 auto",
          padding: "40px",
          backgroundColor: "white",
          borderRadius: "16px",
          boxShadow: "0 8px 25px rgba(0,0,0,0.10)",
        }}
      >
        <h1 style={{ color: "#0f766e", fontSize: "42px", marginBottom: "5px" }}>
          DeliverPuyo
        </h1>

        <h2>Backend optimizado — Avance 8</h2>

        <p>
          Sistema backend para la gestión de usuarios, productos, direcciones,
          pedidos y comprobantes de la aplicación móvil DeliverPuyo.
        </p>

        <div
          style={{
            display: "grid",
            gridTemplateColumns: "repeat(auto-fit, minmax(190px, 1fr))",
            gap: "16px",
            marginTop: "30px",
          }}
        >
          <article style={cardStyle}>
            <h3>Base de datos</h3>
            <p>PostgreSQL y Prisma ORM</p>
          </article>

          <article style={cardStyle}>
            <h3>Caché</h3>
            <p>Redis y estrategia cache-aside</p>
          </article>

          <article style={cardStyle}>
            <h3>Seguridad</h3>
            <p>JWT, autenticación y roles</p>
          </article>

          <article style={cardStyle}>
            <h3>Cola de trabajo</h3>
            <p>BullMQ y generación de comprobantes</p>
          </article>
        </div>

        <h3 style={{ marginTop: "35px" }}>Pruebas disponibles</h3>

        <p>
          <a href="/api/products?page=1&limit=5&fields=id,name,price,stock">
            Consultar productos de la API
          </a>
        </p>

        <p style={{ marginTop: "35px", color: "#64748b" }}>
          Proyecto de Aplicaciones Móviles — Universidad Estatal Amazónica
        </p>
      </section>
    </main>
  );
}

const cardStyle = {
  padding: "18px",
  backgroundColor: "#f8fafc",
  border: "1px solid #cbd5e1",
  borderRadius: "12px",
};
