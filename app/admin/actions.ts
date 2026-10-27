"use server";
import { revalidatePath } from "next/cache";
import { redirect } from "next/navigation";
import { createClient } from "@/lib/supabase/server";
async function adminClient(){const supabase=await createClient();const {data:{user}}=await supabase.auth.getUser();if(!user||user.app_metadata?.role!=="admin")throw new Error("Forbidden: admin access required.");return supabase;}
function value(form:FormData,key:string){return String(form.get(key)||"").trim();}
export async function saveProject(form:FormData){const supabase=await adminClient();const id=value(form,"id");const title=value(form,"title");const category=value(form,"category");const description=value(form,"description");const tags=value(form,"tags").split(",").map(x=>x.trim()).filter(Boolean).slice(0,15);const icon=value(form,"icon")||"◇";const sort_order=Number(value(form,"sort_order")||0);const published=form.get("published")==="on";if(!title||!description||!["quant","ml","data"].includes(category))throw new Error("Please provide valid project details.");const row={title,category,description,tags,icon,sort_order,published};const result=id?await supabase.from("projects").update(row).eq("id",id):await supabase.from("projects").insert(row);if(result.error)throw new Error(result.error.message);revalidatePath("/");revalidatePath("/admin");redirect("/admin");}
export async function deleteProject(form:FormData){const supabase=await adminClient();const id=value(form,"id");if(!id)throw new Error("Missing project id.");const {error}=await supabase.from("projects").delete().eq("id",id);if(error)throw new Error(error.message);revalidatePath("/");revalidatePath("/admin");redirect("/admin");}
export async function signOut(){const supabase=await createClient();await supabase.auth.signOut();redirect("/login");}
