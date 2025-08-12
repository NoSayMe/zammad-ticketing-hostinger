import React, { useEffect, useMemo, useState } from 'react'
import ReactDOM from 'react-dom/client'
import './index.css'

type Ingredient = { id?: string; name: string; unit: 'kg'|'l'|'pcs'; unitCost: number; qpp: number }
type Recipe = { id?: string; name: string; category: string; basePortions: number; notes?: string; ingredients: Ingredient[] }

import { API_BASE, get, send } from './api'

function currency(n: number) { return n.toFixed(2) }

function List() {
  const [recipes, setRecipes] = useState<Recipe[]>([])
  const [query, setQuery] = useState('')
  useEffect(() => { get<Recipe[]>(`/recipes`).then(setRecipes) }, [])
  const filtered = useMemo(() => recipes.filter(r => r.name.toLowerCase().includes(query.toLowerCase())), [recipes, query])
  return (
    <div className="p-4">
      <div className="flex items-center justify-between mb-4">
        <input className="border p-2 rounded w-1/2" placeholder="Search recipes" value={query} onChange={e=>setQuery(e.target.value)} />
        <a href="#/new" className="bg-blue-600 text-white px-4 py-2 rounded">Add</a>
      </div>
      <div className="grid gap-2">
        {filtered.map(r => (
          <a key={r.id} href={`#/edit/${r.id}`} className="border p-3 rounded hover:bg-gray-50 flex justify-between">
            <div>
              <div className="font-semibold">{r.name}</div>
              <div className="text-sm text-gray-500">{r.category} • base {r.basePortions}</div>
            </div>
            <div className="text-sm text-gray-500 self-center">{r.ingredients?.length ?? 0} items</div>
          </a>
        ))}
      </div>
    </div>
  )
}

function Editor({ id }: { id?: string }) {
  const [recipe, setRecipe] = useState<Recipe>({ name: '', category: '', basePortions: 10, notes: '', ingredients: [] })
  useEffect(() => { if (id) get<Recipe>(`/recipes/${id}`).then(setRecipe) }, [id])

  const costPerPortion = useMemo(() => recipe.ingredients.reduce((s, i)=> s + i.qpp * i.unitCost, 0), [recipe])
  const suggested = {
    55: costPerPortion>0? (costPerPortion/(1-0.55)).toFixed(2): '0.00',
    60: costPerPortion>0? (costPerPortion/(1-0.60)).toFixed(2): '0.00',
    65: costPerPortion>0? (costPerPortion/(1-0.65)).toFixed(2): '0.00',
  }

  function save() {
    const payload = {
      name: recipe.name,
      category: recipe.category,
      base_portions: recipe.basePortions,
      notes: recipe.notes,
      ingredients: recipe.ingredients.map(i => ({ name: i.name, unit: i.unit, unit_cost_eur: i.unitCost, qpp: i.qpp }))
    }
    const method = id ? 'PUT' : 'POST'
    const url = id ? `/recipes/${id}` : `/recipes`
    send<any>(method, url, payload).then(data=> { window.location.hash = `#/edit/${data.id}` })
  }

  function addRow() { setRecipe(r => ({ ...r, ingredients: [...r.ingredients, { name:'', unit:'kg', unitCost:0, qpp:0 }] })) }
  function updateRow(idx: number, patch: Partial<Ingredient>) {
    setRecipe(r => { const rows = r.ingredients.slice(); rows[idx] = { ...rows[idx], ...patch }; return { ...r, ingredients: rows } })
  }

  return (
    <div className="p-4 space-y-4">
      <div className="flex gap-2">
        <input className="border p-2 rounded w-1/3" placeholder="Name" value={recipe.name} onChange={e=>setRecipe({...recipe, name:e.target.value})} />
        <input className="border p-2 rounded w-1/3" placeholder="Category" value={recipe.category} onChange={e=>setRecipe({...recipe, category:e.target.value})} />
        <input type="number" className="border p-2 rounded w-32" placeholder="Base portions" value={recipe.basePortions} onChange={e=>setRecipe({...recipe, basePortions: parseInt(e.target.value||'0')})} />
        <button className="bg-green-600 text-white px-4 rounded" onClick={save}>Save</button>
        {id && <a className="bg-gray-600 text-white px-4 rounded" href={`#/print/${id}`}>Print</a>}
      </div>

      <textarea className="border p-2 rounded w-full h-28" placeholder="Notes / guide" value={recipe.notes} onChange={e=>setRecipe({...recipe, notes:e.target.value})} />

      <div>
        <div className="flex justify-between items-center mb-2">
          <div className="font-semibold">Ingredients</div>
          <button className="bg-blue-600 text-white px-3 rounded" onClick={addRow}>Add row</button>
        </div>
        <div className="overflow-auto">
          <table className="min-w-full border">
            <thead className="bg-gray-100">
              <tr>
                <th className="p-2 border">Name</th>
                <th className="p-2 border">Unit</th>
                <th className="p-2 border">Unit cost (€)</th>
                <th className="p-2 border">QPP</th>
                <th className="p-2 border">Actions</th>
              </tr>
            </thead>
            <tbody>
              {recipe.ingredients.map((i, idx) => (
                <tr key={idx}>
                  <td className="p-1 border"><input className="w-full" value={i.name} onChange={e=>updateRow(idx, { name: e.target.value })} /></td>
                  <td className="p-1 border">
                    <select value={i.unit} onChange={e=>updateRow(idx, { unit: e.target.value as any })}>
                      <option value="kg">kg</option>
                      <option value="l">l</option>
                      <option value="pcs">pcs</option>
                    </select>
                  </td>
                  <td className="p-1 border"><input type="number" step="0.0001" value={i.unitCost} onChange={e=>updateRow(idx, { unitCost: parseFloat(e.target.value||'0') })} /></td>
                  <td className="p-1 border"><input type="number" step="0.000001" value={i.qpp} onChange={e=>updateRow(idx, { qpp: parseFloat(e.target.value||'0') })} /></td>
                  <td className="p-1 border">
                    <button className="text-red-600" onClick={()=> setRecipe(r => ({...r, ingredients: r.ingredients.filter((_,j)=>j!==idx)}))}>Delete</button>
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      </div>

      <div className="bg-gray-50 p-3 rounded">
        <div>Cost/portion: <b>€ {currency(costPerPortion)}</b></div>
        <div className="text-sm text-gray-600">Suggested (55/60/65%): € {suggested[55]} / € {suggested[60]} / € {suggested[65]}</div>
      </div>

      {id && <Scale id={id} />}
    </div>
  )
}

function Scale({ id }: { id: string }) {
  const [portions, setPortions] = useState(10)
  const [result, setResult] = useState<any>(null)
  useEffect(()=>{ get<any>(`/recipes/${id}/scale?portions=${portions}`).then(setResult) }, [id, portions])
  return (
    <div className="border rounded p-3">
      <div className="flex items-center gap-2 mb-2">
        <div className="font-semibold">Scaling</div>
        <input type="number" className="border p-1 rounded w-24" value={portions} onChange={e=>setPortions(parseInt(e.target.value||'1'))} />
      </div>
      {result && (
        <div>
          <div className="text-sm text-gray-600 mb-2">Total cost: € {currency(result.totalCost)}</div>
          <table className="min-w-full border text-sm">
            <thead className="bg-gray-100">
              <tr>
                <th className="p-1 border">Name</th>
                <th className="p-1 border">Unit</th>
                <th className="p-1 border">Scaled qty</th>
              </tr>
            </thead>
            <tbody>
              {result.ingredients.map((i:any) => (
                <tr key={i.id}>
                  <td className="p-1 border">{i.name}</td>
                  <td className="p-1 border">{i.unit}</td>
                  <td className="p-1 border">{i.scaledQty}</td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      )}
    </div>
  )
}

function Print({ id }: { id: string }) {
  const [portions, setPortions] = useState(10)
  const [data, setData] = useState<any>(null)
  useEffect(()=>{ get<any>(`/recipes/${id}/scale?portions=${portions}`).then(setData) }, [id, portions])
  useEffect(()=>{ if (data) setTimeout(()=>window.print(), 300) }, [data])
  if (!data) return <div className=\"p-4\">Loading…</div>
  return (
    <div className=\"p-8 print:p-0 print:m-0\">
      <div className=\"flex justify-between items-center mb-4\">
        <div>
          <div className=\"text-2xl font-bold\">{data.name}</div>
          <div className=\"text-gray-600\">{data.category} • {data.portions} portions</div>
        </div>
        <input type=\"number\" className=\"border p-1 rounded w-24 no-print\" value={portions} onChange={e=>setPortions(parseInt(e.target.value||'1'))} />
      </div>
      <table className=\"min-w-full border text-sm\">
        <thead className="bg-gray-100">
          <tr>
            <th className="p-1 border">Name</th>
            <th className="p-1 border">Unit</th>
            <th className="p-1 border">Qty</th>
          </tr>
        </thead>
        <tbody>
          {data.ingredients.map((i:any) => (
            <tr key={i.id}>
              <td className="p-1 border">{i.name}</td>
              <td className="p-1 border">{i.unit}</td>
              <td className="p-1 border">{i.scaledQty}</td>
            </tr>
          ))}
        </tbody>
      </table>
      {data.notes && (
        <div className="mt-6">
          <div className="font-semibold mb-1">Notes</div>
          <div className="whitespace-pre-wrap">{data.notes}</div>
        </div>
      )}
      <style>{`@media print { .no-print { display: none } }`}</style>
    </div>
  )
}

function Router() {
  const hash = window.location.hash
  const [, route, param] = hash.replace('#','').split('/')
  if (route === 'new') return <Editor />
  if (route === 'edit' && param) return <Editor id={param} />
  if (route === 'print' && param) return <Print id={param} />
  return <List />
}

function App() {
  return (
    <div className="min-h-screen">
      <div className="bg-slate-800 text-white p-3"><a href="#/">Recipe Manager</a></div>
      <div className="max-w-5xl mx-auto">
        <Router />
      </div>
    </div>
  )
}

ReactDOM.createRoot(document.getElementById('root')!).render(
  <React.StrictMode>
    <App />
  </React.StrictMode>,
)