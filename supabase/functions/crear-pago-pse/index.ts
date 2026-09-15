// supabase/functions/crear-pago-pse/index.ts
import { serve } from "https://deno.land/std@0.168.0/http/server.ts";

const EPAYCO_PUBLIC_KEY = Deno.env.get("EPAYCO_PUBLIC_KEY")!;
const EPAYCO_PRIVATE_KEY = Deno.env.get("EPAYCO_PRIVATE_KEY")!;

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
};

serve(async (req) => {
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }

  try {
    const body = await req.json();

        // 1️⃣ Obtener token de acceso de ePayco (login con Basic Auth)
        const credenciales = btoa(`${EPAYCO_PUBLIC_KEY}:${EPAYCO_PRIVATE_KEY}`);

        const authRes = await fetch("https://apify.epayco.co/login", {
          method: "POST",
          headers: {
            "Content-Type": "application/json",
            "Authorization": `Basic ${credenciales}`,
          },
        });
        const authData = await authRes.json();
        const token = authData.token;

        if (!token) {
          throw new Error(`No se pudo autenticar con ePayco: ${JSON.stringify(authData)}`);
        }
    // 2️⃣ Crear el cargo PSE
    const payload = {
      bank: body.banco, // código del banco elegido
      docType: body.tipoDocumento, // CC, CE, NIT
      docNumber: body.numeroDocumento,
      name: body.nombreCompleto,
      lastName: body.apellido ?? "",
      email: body.correo,
      cellPhone: body.telefono,
      phone: body.telefono,
      address: body.direccion,
      country: "CO",
      city: body.ciudad ?? "Bogota",
      ip: body.ip ?? "127.0.0.1",
      typePerson: body.tipoPersona, // 0 = natural, 1 = jurídica
      value: body.total.toString(),
      currency: "cop",
      description: `Pedido Buitrón Coffee`,
      invoice: body.idPedido.toString(),
      urlResponse: body.urlRespuesta,
      urlConfirmation: body.urlConfirmacion,
      methodConfirmation: "GET",
    };

    const chargeRes = await fetch("https://apify.epayco.co/payment/process/pse", {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
        Authorization: `Bearer ${token}`,
      },
      body: JSON.stringify(payload),
    });

    const chargeData = await chargeRes.json();

    return new Response(JSON.stringify(chargeData), {
      headers: { ...corsHeaders, "Content-Type": "application/json" },
    });
  } catch (error) {
    return new Response(JSON.stringify({ error: error.message }), {
      status: 400,
      headers: { ...corsHeaders, "Content-Type": "application/json" },
    });
  }
});