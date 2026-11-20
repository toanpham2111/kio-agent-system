# PostgreSQL & Supabase RLS Deep Dive

## 1. Security Definer vs Security Invoker Functions
- **Security Invoker (Default)**: Function executes with the permissions of the calling user. Respects RLS.
- **Security Definer**: Function executes with the privileges of the creator (postgres/superuser). **Bypasses RLS**.
  - Always specify `SET search_path = public, pg_temp;` inside `SECURITY DEFINER` functions to prevent search path injection attacks.

```sql
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public, pg_temp
AS $$
BEGIN
  INSERT INTO public.profiles (id, email, full_name)
  VALUES (new.id, new.email, new.raw_user_meta_data->>'full_name');
  RETURN NEW;
END;
$$;
```

## 2. Multi-Role RBAC Policy Template
```sql
-- Read: Anyone can read published items
CREATE POLICY "Public read published" ON articles
  FOR SELECT USING (status = 'published');

-- Write: Only authors can update their own drafts
CREATE POLICY "Authors update drafts" ON articles
  FOR UPDATE USING (
    author_id = (SELECT auth.uid()) 
    AND status = 'draft'
  );

-- Admin: Superusers/Admins can do everything
CREATE POLICY "Admins full access" ON articles
  FOR ALL USING (
    EXISTS (
      SELECT 1 FROM user_roles
      WHERE user_id = (SELECT auth.uid())
      AND role = 'admin'
    )
  );
```
