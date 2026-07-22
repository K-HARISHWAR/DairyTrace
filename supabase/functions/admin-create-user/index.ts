// @ts-ignore
import { serve } from 'https://deno.land/std@0.177.0/http/server.ts'
// @ts-ignore
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2.7.1'
// @ts-ignore
declare const Deno: any;

serve(async (req: Request) => {
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: { 'Access-Control-Allow-Origin': '*', 'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type' } })
  }

  try {
    const authHeader = req.headers.get('Authorization');
    if (!authHeader) throw new Error('Missing Authorization header');
    const token = authHeader.replace('Bearer ', '');

    const supabaseClient = createClient(
      Deno.env.get('SUPABASE_URL') ?? '',
      Deno.env.get('SUPABASE_ANON_KEY') ?? ''
    )

    let user;
    try {
      const { data, error } = await supabaseClient.auth.getUser(token)
      if (error) throw error;
      user = data.user;
    } catch (e) {
      throw new Error('getUser failed: ' + (e as Error).message);
    }
    
    if (!user) throw new Error('Unauthorized: No user found')

    const supabaseAdmin = createClient(
      Deno.env.get('SUPABASE_URL') ?? '',
      Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') ?? ''
    )

    const { data: profile } = await supabaseAdmin.from('profiles').select('role').eq('id', user.id).single()
    if (profile?.role !== 'admin') throw new Error('Not an admin')

    const body = await req.json();
    const { email, password, full_name, phone, role, collection_centre_id, distributor_organisation_id } = body;

    if (!['collection_staff', 'distributor'].includes(role)) {
       throw new Error('Invalid role');
    }

    if (role === 'collection_staff' && !collection_centre_id) {
       throw new Error('Collection staff must have a collectionCentreId');
    }

    if (role === 'distributor' && !distributor_organisation_id) {
       throw new Error('Distributor must have a distributorOrganisationId');
    }

    const { data: authData, error: authError } = await supabaseAdmin.auth.admin.createUser({
      email,
      password,
      email_confirm: true
    })

    if (authError) throw authError

    const { error: profileError } = await supabaseAdmin.from('profiles').upsert({
      id: authData.user.id,
      email,
      full_name: full_name,
      phone,
      role,
      collection_centre_id: role === 'collection_staff' ? collection_centre_id : null,
      distributor_organisation_id: role === 'distributor' ? distributor_organisation_id : null
    })

    if (profileError) {
      // rollback user creation
      await supabaseAdmin.auth.admin.deleteUser(authData.user.id)
      throw profileError
    }

    return new Response(JSON.stringify({ user: authData.user }), {
      headers: { 'Content-Type': 'application/json', 'Access-Control-Allow-Origin': '*' },
      status: 200,
    })
  } catch (error) {
    const err = error as Error;
    return new Response(JSON.stringify({ error: err.message ?? String(error) }), {
      headers: { 'Content-Type': 'application/json', 'Access-Control-Allow-Origin': '*' },
      status: 400,
    })
  }
})
